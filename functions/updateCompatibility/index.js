const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.AWS_REGION });
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const start = Date.now();
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,PUT"
  };

  try {
    const id = event.pathParameters?.id;
    if (!id) {
      throw new Error('Missing ID in path parameters');
    }

    const body = JSON.parse(event.body || '{}');
    const { user1, user2, score } = body;

    // Validate input
    if (!user1 || !user2 || typeof score !== 'number' || score < 0 || score > 100) {
      const latency = Date.now() - start;
      console.log(JSON.stringify({
        level: "Error",
        operation: "PUT",
        status: 400,
        latency: latency,
        error: 'Invalid input: user1, user2, and score (0-100) are required'
      }));
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Invalid input: user1, user2, and score (0-100) are required' })
      };
    }

    await dynamodb.update({
      TableName: process.env.TABLE_NAME,
      Key: { id },
      UpdateExpression: 'set score = :score, user1 = :user1, user2 = :user2',
      ExpressionAttributeValues: {
        ':score': score,
        ':user1': user1,
        ':user2': user2
      },
      ConditionExpression: 'attribute_exists(id)'
    }).promise();

    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Info",
      operation: "PUT",
      status: 200,
      latency: latency
    }));
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ message: 'Compatibility updated' })
    };
  } catch (error) {
    const latency = Date.now() - start;
    console.log(JSON.stringify({
      level: "Error",
      operation: "PUT",
      status: 500,
      latency: latency,
      error: error.message
    }));
    return {
      statusCode: error.message.includes('Invalid input') ? 400 : 500,
      headers: corsHeaders,
      body: JSON.stringify({ error: error.message.includes('Invalid input') ? error.message : 'Internal server error' })
    };
  }
};