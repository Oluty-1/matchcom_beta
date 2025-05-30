const { DynamoDBClient, GetItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    const id = event.pathParameters.id;

    const result = await dynamoDBClient.send(new GetItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: id }
      }
    }));

    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: 'Compatibility result not found' })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        id: result.Item.id.S,
        user1: result.Item.user1.S,
        age1: parseInt(result.Item.age1.N),
        user2: result.Item.user2.S,
        age2: parseInt(result.Item.age2.N),
        score: parseFloat(result.Item.score.N)
      })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};