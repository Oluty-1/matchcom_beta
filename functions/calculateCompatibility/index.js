const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');
const crypto = require('crypto');

const sqsClient = new SQSClient({ region: process.env.AWS_REGION });
const QUEUE_URL = process.env.SQS_QUEUE_URL;

exports.handler = async (event) => {
  const start = Date.now(); // Start time for latency measurement
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST"
  };

  try {
    const body = JSON.parse(event.body || '{}');
    const { user1, user2, age1, age2, score } = body;

    // Input validation
    if (!user1 || !user2 || !age1 || !age2 || !score || age1 <= 0 || age2 <= 0 || score < 0 || score > 100) {
      const latency = Date.now() - start;
      console.log(JSON.stringify({
        level: "Error",
        operation: "POST",
        status: 400,
        latency: latency,
        error: 'Invalid input: all fields required, ages must be positive, score must be 0-100'
      }));
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Invalid input: all fields required, ages must be positive, score must be 0-100' })
      };
    }

    const id = crypto.randomUUID();

    // Send message to SQS
    await sqsClient.send(new SendMessageCommand({
      QueueUrl: QUEUE_URL,
      MessageBody: JSON.stringify({ id, user1, user2, age1, age2, score })
    }));

    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Info",
      operation: "POST",
      status: 200,
      latency: latency
    }));
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ id, score })
    };
  } catch (error) {
    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Error",
      operation: "POST",
      status: 500,
      latency: latency,
      error: error.message
    }));
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};