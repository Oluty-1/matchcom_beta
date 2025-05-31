const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.AWS_REGION });
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const start = Date.now(); // Start time for latency measurement
  try {
    const id = event.pathParameters.id;
    const body = JSON.parse(event.body);

    // Update item in DynamoDB
    await dynamodb.update({
      TableName: process.env.TABLE_NAME,
      Key: { id },
      UpdateExpression: 'set score = :score, user1 = :user1, user2 = :user2',
      ExpressionAttributeValues: {
        ':score': body.score || 0,
        ':user1': body.user1,
        ':user2': body.user2
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
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};
