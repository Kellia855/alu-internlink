const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

function requireField(data, field) {
  if (!data || data[field] === undefined || data[field] === null) {
    throw new Error(`Missing required field: ${field}`);
  }
  return data[field];
}

async function createNotification({ userId, title, body }) {
  if (!userId) return;

  await db.collection('notifications').add({
    userId,
    title,
    body,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

function statusToText(status) {
  switch (status) {
    case 'accepted':
      return 'accepted';
    case 'rejected':
      return 'rejected';
    case 'pending':
      return 'pending';
    default:
      return String(status);
  }
}

// 1) When a new application is created, notify the startup.
exports.onApplicationCreateNotifyStartup = functions.firestore
  .document('applications/{applicationId}')
  .onCreate(async (snap) => {
    const data = snap.data();

    const startupId = requireField(data, 'startupId');
    const studentName = data.studentName || 'Student';
    const opportunityTitle = data.opportunityTitle || 'Opportunity';
    const status = data.status || 'pending';

    const title = 'New application received';
    const body = `${studentName} applied to “${opportunityTitle}” (${statusToText(status)}).`;

    await createNotification({
      userId: startupId,
      title,
      body,
    });
  });

// 2) When application status changes, notify the student.
exports.onApplicationUpdateNotifyStudentOnStatusChange = functions.firestore
  .document('applications/{applicationId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeStatus = before.status;
    const afterStatus = after.status;

    // Only notify if status actually changed.
    if (beforeStatus === afterStatus) return null;

    const studentId = requireField(after, 'studentId');
    const opportunityTitle = after.opportunityTitle || 'Opportunity';
    const companyName = after.companyName || undefined;

    const statusText = statusToText(afterStatus);

    const title = `Application ${statusText}`;
    const body = companyName
      ? `Your application to “${opportunityTitle}” at ${companyName} is ${statusText}.`
      : `Your application to “${opportunityTitle}” is ${statusText}.`;

    await createNotification({
      userId: studentId,
      title,
      body,
    });

    return null;
  });

