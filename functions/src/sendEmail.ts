import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineString, defineSecret } from 'firebase-functions/params';
import { createTransport, Transporter } from "nodemailer";

async function sendEmailWithTransporter(
  transporter: Transporter,
  mailOptions: {
    from: string;
    to: string;
    subject: string;
    text: string;
  }
): Promise<void> {
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log("Successfully sent email:", info.response);
  } catch (error) {
    console.error("Failed to send email:", error);
    throw new HttpsError("internal", "Failed to send email.");
  }
}

//
// 環境変数からメールアカウント情報を取得
const mail = defineString('EMAIL_ADDRESS');
const password = defineSecret('EMAIL_PASS');

export const sendEmail = onCall({ secrets: [password] },async (request) => {
  const { subject, text} = request.data;

  // リクエストデータのバリデーション
  if (!subject || !text ) {
    throw new HttpsError(
      "invalid-argument",
      "Subject, text, and to fields are required."
    );
  }

  // 環境変数のチェック
  if (!mail.value() || !password.value()) {
    console.error("Missing MAIL_ACCOUNT or MAIL_PASSWORD environment variables.");
    throw new HttpsError("internal", "Email configuration is not properly set.");
  }

  // メール送信オプションの設定
  const mailOptions = {
    from: mail.value(),
    to:  mail.value(),
    subject: subject,
    text: text,
  };

  // メールトランスポーターの作成
  const transporter = createTransport({
    service: "gmail",
    auth: {
      user: mail.value(),
      pass: password.value(),
    },
  });


  // メールの送信
  await sendEmailWithTransporter(transporter, mailOptions);
});