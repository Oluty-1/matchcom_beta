const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  const start = Date.now(); // Start time for latency measurement
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST"
  };

  try {
    for (const record of event.Records) {
      const message = JSON.parse(record.body);
      const { id, user1, user2, age1, age2, score } = message;

      await dynamoDBClient.send(new PutItemCommand({
        TableName: TABLE_NAME,
        Item: {
          id: { S: id },
          user1: { S: user1 },
          age1: { N: age1.toString() },
          user2: { S: user2 },
          age2: { N: age2.toString() },
          score: { N: score.toString() }
        }
      }));
    }

    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Info",
      operation: "SQS",
      status: 200,
      latency: latency
    }));
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ message: 'Processed successfully' })
    };
  } catch (error) {
    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Error",
      operation: "SQS",
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