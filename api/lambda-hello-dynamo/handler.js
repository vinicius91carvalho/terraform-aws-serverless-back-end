const database = require('./database.js');

exports.helloDynamo = async event => {

    const data = await database.getItem(getId(event)).promise();

    return {
        statusCode: 200,
        body: JSON.stringify(
            {
                'name': data['Item']['name'],
                'event': event
            },
            null,
            2
        )
    };
};


function getId(event) {
    return event['queryStringParameters']['id'];
}

exports.getId = getId;
