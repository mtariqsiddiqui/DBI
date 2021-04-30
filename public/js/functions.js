$.ajax({
    type: 'DELETE',
    url: 'http://127.0.0.1:3000/biller-api/biller',
    contentType: 'application/json',
    data: JSON.stringify(data), // access in body
}).done(function () {
    console.log('SUCCESS');
}).fail(function (msg) {
    console.log('FAIL');
}).always(function (msg) {
    console.log('ALWAYS');
});