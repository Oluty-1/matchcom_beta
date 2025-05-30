const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.AWS_REGION });
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  try {
    const id = event.pathParameters.id;
    const body = JSON.parse(event.body);

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

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Compatibility updated' })
    };
  } catch (error) {
    console.error(JSON.stringify({ level: 'ERROR', message: error.message }));
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};