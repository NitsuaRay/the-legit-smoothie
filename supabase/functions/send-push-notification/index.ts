import { GoogleAuth } from "npm:google-auth-library@9.15.1";
import { createClient } from "npm:@supabase/supabase-js@2";

// ============================================================
// ENVIRONMENT
// ============================================================

const FIREBASE_PROJECT_ID =
  Deno.env.get("FIREBASE_PROJECT_ID");

const FIREBASE_CLIENT_EMAIL =
  Deno.env.get("FIREBASE_CLIENT_EMAIL");

const FIREBASE_PRIVATE_KEY =
  Deno.env
    .get("FIREBASE_PRIVATE_KEY")
    ?.replace(/\\n/g, "\n");

const SUPABASE_URL =
  Deno.env.get("SUPABASE_URL");

const PUSH_WEBHOOK_SECRET =
  Deno.env.get("PUSH_WEBHOOK_SECRET");

// Support current Supabase secret-key format first,
// with the legacy service-role key as fallback.
const SUPABASE_SECRET_KEY = (() => {
  const secretKeys =
    Deno.env.get("SUPABASE_SECRET_KEYS");

  if (secretKeys) {
    try {
      const parsed =
        JSON.parse(secretKeys);

      if (parsed.default) {
        return parsed.default as string;
      }
    } catch {
      // Fall through to legacy key.
    }
  }

  return Deno.env.get(
    "SUPABASE_SERVICE_ROLE_KEY",
  );
})();

// ============================================================
// TYPES
// ============================================================

interface NotificationRecord {
  id: string;
  user_id: string;
  order_id: string | null;

  type: string;
  title: string;
  message: string;

  is_read: boolean;
  created_at: string;
}

interface DatabaseWebhookPayload {
  type: "INSERT";
  table: string;
  schema: string;

  record: NotificationRecord;

  old_record: null;
}

interface DeviceToken {
  id: string;
  token: string;
}

// ============================================================
// SUPABASE ADMIN CLIENT
// ============================================================

if (!SUPABASE_URL || !SUPABASE_SECRET_KEY) {
  throw new Error(
    "Supabase server credentials are missing.",
  );
}

const supabaseAdmin =
  createClient(
    SUPABASE_URL,
    SUPABASE_SECRET_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  );

// ============================================================
// FIREBASE ACCESS TOKEN
// ============================================================

async function getFirebaseAccessToken():
  Promise<string> {
  if (
    !FIREBASE_CLIENT_EMAIL ||
    !FIREBASE_PRIVATE_KEY
  ) {
    throw new Error(
      "Firebase service-account credentials are missing.",
    );
  }

  const auth = new GoogleAuth({
    credentials: {
      client_email:
        FIREBASE_CLIENT_EMAIL,

      private_key:
        FIREBASE_PRIVATE_KEY,
    },

    scopes: [
      "https://www.googleapis.com/auth/firebase.messaging",
    ],
  });

  const client =
    await auth.getClient();

  const accessToken =
    await client.getAccessToken();

  if (!accessToken.token) {
    throw new Error(
      "Unable to obtain Firebase access token.",
    );
  }

  return accessToken.token;
}

// ============================================================
// SEND ONE FCM MESSAGE
// ============================================================

async function sendPush({
  token,
  title,
  message,
  orderId,
  type,
  accessToken,
}: {
  token: string;
  title: string;
  message: string;
  orderId: string | null;
  type: string;
  accessToken: string;
}) {
  if (!FIREBASE_PROJECT_ID) {
    throw new Error(
      "FIREBASE_PROJECT_ID is missing.",
    );
  }

  const data: Record<string, string> = {
    type,
  };

  if (orderId) {
    data.order_id = orderId;
  }

  const response =
    await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
      {
        method: "POST",

        headers: {
          Authorization:
            `Bearer ${accessToken}`,

          "Content-Type":
            "application/json",
        },

        body: JSON.stringify({
          message: {
            token,

            notification: {
              title,
              body: message,
            },

            data,

            android: {
              priority: "high",

              notification: {
                sound: "default",
              },
            },
          },
        }),
      },
    );

  const result =
    await response.json();

  return {
    ok: response.ok,
    status: response.status,
    result,
  };
}

// ============================================================
// EDGE FUNCTION
// ============================================================

Deno.serve(async (req: Request) => {
  // ----------------------------------------------------------
  // METHOD CHECK
  // ----------------------------------------------------------

  if (req.method !== "POST") {
    return jsonResponse(
      {
        success: false,
        error: "Method not allowed.",
      },
      405,
    );
  }

  // ----------------------------------------------------------
  // VERIFY WEBHOOK SECRET
  // ----------------------------------------------------------

  if (!PUSH_WEBHOOK_SECRET) {
    console.error(
      "PUSH_WEBHOOK_SECRET is not configured.",
    );

    return jsonResponse(
      {
        success: false,
        error: "Server configuration error.",
      },
      500,
    );
  }

  const receivedSecret =
    req.headers.get("X-Webhook-Secret");

  if (receivedSecret !== PUSH_WEBHOOK_SECRET) {
    console.warn(
      "Rejected unauthorized push webhook request.",
    );

    return jsonResponse(
      {
        success: false,
        error: "Unauthorized.",
      },
      401,
    );
  }

  try {
    // --------------------------------------------------------
    // DATABASE WEBHOOK PAYLOAD
    // --------------------------------------------------------

    const payload =
      (await req.json()) as DatabaseWebhookPayload;

    if (
      payload.type !== "INSERT" ||
      payload.table !== "notifications" ||
      payload.schema !== "public" ||
      !payload.record
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            "Invalid notifications webhook payload.",
        },
        400,
      );
    }

    const notification =
      payload.record;

    // --------------------------------------------------------
    // VALIDATE NOTIFICATION
    // --------------------------------------------------------

    if (
      !notification.user_id ||
      !notification.title ||
      !notification.message
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            "Notification record is incomplete.",
        },
        400,
      );
    }

    // --------------------------------------------------------
    // GET USER DEVICE TOKENS
    // --------------------------------------------------------

    const {
      data: devices,
      error: deviceError,
    } = await supabaseAdmin
      .from("device_tokens")
      .select("id, token")
      .eq(
        "user_id",
        notification.user_id,
      );

    if (deviceError) {
      throw new Error(
        `Unable to load device tokens: ${deviceError.message}`,
      );
    }

    const registeredDevices =
      (devices ?? []) as DeviceToken[];

    // --------------------------------------------------------
    // USER HAS NO REGISTERED DEVICE
    // --------------------------------------------------------

    if (registeredDevices.length === 0) {
      console.log(
        `No registered devices for user ${notification.user_id}.`,
      );

      return jsonResponse(
        {
          success: true,
          sent: 0,
          failed: 0,
          message:
            "User has no registered devices.",
        },
        200,
      );
    }

    // --------------------------------------------------------
    // FIREBASE AUTHENTICATION
    // --------------------------------------------------------

    const accessToken =
      await getFirebaseAccessToken();

    // --------------------------------------------------------
    // SEND TO ALL REGISTERED DEVICES
    // --------------------------------------------------------

    const results =
      await Promise.all(
        registeredDevices.map(
          async (device) => {
            try {
              const result =
                await sendPush({
                  token: device.token,

                  title:
                    notification.title,

                  message:
                    notification.message,

                  orderId:
                    notification.order_id,

                  type:
                    notification.type,

                  accessToken,
                });

              if (!result.ok) {
                console.error(
                  `FCM send failed for device ${device.id}:`,
                  result.result,
                );
              }

              return result;
            } catch (error) {
              console.error(
                `FCM request failed for device ${device.id}:`,
                error,
              );

              return {
                ok: false,
                status: 500,
                result: {
                  error:
                    error instanceof Error
                      ? error.message
                      : "Unknown FCM error.",
                },
              };
            }
          },
        ),
      );

    // --------------------------------------------------------
    // RESULT COUNTS
    // --------------------------------------------------------

    const sent =
      results.filter(
        (result) => result.ok,
      ).length;

    const failed =
      results.length - sent;

    console.log(
      `Push result for notification ${notification.id}: ` +
        `${sent} sent, ${failed} failed.`,
    );

    // --------------------------------------------------------
    // RESPONSE
    // --------------------------------------------------------

    return jsonResponse(
      {
        success: failed === 0,
        sent,
        failed,
      },
      failed === results.length
        ? 502
        : 200,
    );
  } catch (error) {
    console.error(
      "send-push-notification error:",
      error,
    );

    return jsonResponse(
      {
        success: false,

        error:
          error instanceof Error
            ? error.message
            : "Unknown server error.",
      },
      500,
    );
  }
});

// ============================================================
// JSON RESPONSE
// ============================================================

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,

      headers: {
        "Content-Type":
          "application/json",
      },
    },
  );
}