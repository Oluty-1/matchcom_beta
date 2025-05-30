const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');
const crypto = require('crypto');

const sqsClient = new SQSClient({ region: process.env.AWS_REGION });
const QUEUE_URL = process.env.SQS_QUEUE_URL;

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { user1, user2, age1, age2, score } = body;

    if (!user1 || !user2 || !age1 || !age2 || !score || age1 <= 0 || age2 <= 0 || score < 0 || score > 100) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid input: all fields required, ages must be positive, score must be 0-100' })
      };
    }

    const id = crypto.randomUUID();

    await sqsClient.send(new SendMessageCommand({
      QueueUrl: QUEUE_URL,
      MessageBody: JSON.stringify({ id, user1, user2, age1, age2, score })
    }));

    return {
      statusCode: 200,
      body: JSON.stringify({ id, score })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};