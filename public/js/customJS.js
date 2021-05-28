/**
 * nRecFlag => nRecFlag is record flag for controlling Create, Update and Delete
 * nRecFlag = 0 is Reset 
 * nRecFlag = 1 is for Update
 * nRecFlag = 2 is for Delete
 */
var nRecFlag = 0;

window.onload = function () {
    console.log('Window loaded.');

    if(document.getElementById("api_url") !== null)
        retreiveRecord();
}

function createRecord() {
    console.log("createRecord >>");
    let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
    backendHandler("POST", url);
    clearFormData();
    console.log("createRecord <<");
}

function retreiveRecord(__id) {
    console.log("retreiveRecord >>");
    if (__id === undefined) {
        nRecFlag = 0;
        let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[1];
        backendHandler("GET", url, nRecFlag);
    } else {
        nRecFlag = 1;
        let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0] 
            + "?eid=" + __id;
        backendHandler("GET", url, nRecFlag);
    }
    console.log("retreiveRecord <<");
}

function updateRecord() {
    console.log("updateRecord >>");
    let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
    backendHandler("PATCH", url);
    clearFormData();
    console.log("updateRecord <<");

}

function deleteRecord(__id) {
    console.log("deleteRecord >>");
    document.getElementById('_id').value = __id;
    let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
    backendHandler("DELETE", url);
    clearFormData();
    console.log("deleteRecord <<");

}

function backendHandler(method, url, nRecFlag) {
    console.log("backendHandler >>");
    const xhr = new XMLHttpRequest();
    //Send the proper header information along with the request
    switch (method) {
        case "GET":
            xhr.open("GET", url, true);
            break;
        case "POST":
            xhr.open("POST", url, true);
            break;
        case "PATCH":
            xhr.open("PATCH", url, true);
            break;
        case "DELETE":
            xhr.open("DELETE", url, true);
            break;
        default:
            xhr.open("HEAD", url, true);
    }
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) { // Success
            if (method === "GET") {
                if (nRecFlag === 1) { // Only True in case of single record retreval
                    populateFormWithData(JSON.parse(xhr.responseText))
                    nRecFlag = 0; // reset the value of nRecFlag
                } else {
                    document.getElementById('entity_table').getElementsByTagName('tbody')[0].innerHTML = ''
                    populateTableWithData(JSON.parse(xhr.responseText));
                    nRecFlag = 0; // reset the value of nRecFlag
                }
            } else {
                if (nRecFlag !== 0)
                    retreiveRecord();
                nRecFlag = 0;
                if (method === "DELETE")
                    displayMessage('SUCCESS', 'Record has been deleted successfully.');
                else if (method === "POST")
                    displayMessage('SUCCESS', 'Record has been created successfully.');
                else if (method === "PATCH")
                    displayMessage('SUCCESS', 'Record has been updated successfully.');
                else
                    displayMessage();
            }
        } else if (this.readyState == 4 && this.status >= 400) { // Failure
            displayMessage('FAILURE', JSON.parse(xhr.responseText)['statusMessage'])
        }
    };
    xhr.send(prepareDataForSubmission());
    console.log("backendHandler <<");
}

function prepareDataForSubmission() {
    console.log("prepareDataForSubmission >>");

    let _entity = { e: {} };
    if(nRecFlag > 0)
        _entity["e"]['_id'] = document.getElementById('_id').value;
    if(nRecFlag === 2) {
        document.querySelectorAll("input.form-control").forEach((el) => {
            if (el.type === 'text')
                _entity["e"][el.id] = 'dummy';
            else if (el.type === 'number')
                _entity["e"][el.id] = parseInt(0);
        });
    }
    document.querySelectorAll("input.form-control").forEach((el) => {
        if(el.value.trim().length > 0) {
            if (el.type === 'text')
                _entity["e"][el.id] = el.value;
            else if (el.type === 'number')
                _entity["e"][el.id] = parseInt(el.value);
        }
    });
    console.log("prepareDataForSubmission <<");
    return JSON.stringify(_entity);
}

function populateFormWithData(jRec) {
    console.log("populateFormWithData >>");

    Object.keys(jRec).forEach((k) => {
        document.getElementById(k).value = jRec[k];
    });

    console.log("populateFormWithData <<");
}

function clearFormData() {
    console.log("clearFormData >>");
    displayMessage();
    document.getElementById('_id').value = '';
    document.querySelectorAll("input.form-control").forEach((el) => { el.value = ''; });
    console.log("clearFormData <<");
}

function populateTableWithData(jRec) {
    console.log("populateTableWithData >>");    
    const tbodyRef = document.getElementById('entity_table').getElementsByTagName('tbody')[0];
    jRec.forEach((r) => {
        const newRow = tbodyRef.insertRow(); // create row for each iteration
        let edtId = '';
        Object.keys(r).forEach((k) => {
            const newCell = newRow.insertCell();
            const cellText = document.createTextNode(r[k]);
            newCell.appendChild(cellText);
            if (k === '_id')
                edtId = r[k];
        });
        const newCell = newRow.insertCell();
        const edtButton = document.createElement("button");
        edtButton.setAttribute('class', 'btn btn-outline-warning btn-sm');
        edtButton.setAttribute('onclick', 'retreiveRecord("' + edtId + '");');
        edtButton.innerHTML = 'Edit';
        newCell.appendChild(edtButton);
        newCell.appendChild(document.createTextNode(" "));

        const delButton = document.createElement("button");
        delButton.setAttribute('class', 'btn btn-outline-danger btn-sm');
        delButton.setAttribute('onclick', 'nRecFlag=2;deleteRecord("' + edtId + '");');
        delButton.innerHTML = 'Delete';
        newCell.appendChild(delButton);
    });

    console.log("populateTableWithData <<");
}

function formSubmit() {
    console.log("formSubmit >>", nRecFlag);
    displayMessage();
    if(document.getElementsByTagName('form')[0].reportValidity()) {
        if(nRecFlag === 0){
            document.getElementById('_id').value = '';
            createRecord();
        } else if(nRecFlag === 1) {
            updateRecord();
        }
    } else {
        displayMessage('WARNING', 'Please enter the correct data.');
    }
    console.log("formSubmit <<");
}

function displayMessage(messageType, messageText) {
    let dmes = document.getElementById("notify_success");
    let dmef = document.getElementById("notify_failure");
    let dmew = document.getElementById("notify_warning");
    dmes.innerHTML = '';
    dmes.classList.add('d-none');
    dmef.innerHTML = '';
    dmef.classList.add('d-none');
    dmew.innerHTML = '';
    dmew.classList.add('d-none');
    if(messageType === 'SUCCESS') {
        dmes.innerHTML = messageText;
        dmes.classList.remove('d-none');
    } else if (messageType === 'FAILURE') {
        dmef.innerHTML = messageText;
        dmef.classList.remove('d-none');
    } else if (messageType === 'WARNING') {
        dmew.innerHTML = messageText;
        dmew.classList.remove('d-none');
    }
}