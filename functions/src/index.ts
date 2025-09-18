import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getMessaging} from "firebase-admin/messaging";
import {getFirestore} from "firebase-admin/firestore";

initializeApp();

export const sendStatusUpdateNotification = onDocumentUpdated(
  {
    region: "asia-south1",
    document: "reports/{reportId}",
  },
  async (event) => {
    if (!event.data) {
      console.log("No data associated with the event");
      return;
    }

    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    if (beforeData.status === afterData.status) {
      console.log("Status did not change, no notification sent.");
      return;
    }

    const userId = afterData.userId;
    if (!userId) {
      console.log("No user ID found in the report.");
      return;
    }

    const userDoc = await getFirestore().collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token found for user:", userId);
      return;
    }

    const body = `The status of your report for '${afterData.category}'` +
                 ` is now '${afterData.status}'.`;

    const payload = {
      notification: {
        title: "Your Report Status Has Updated!",
        body: body,
      },
    };

    console.log("Sending notification to token:", fcmToken);
    await getMessaging().sendToDevice(fcmToken, payload);
  });