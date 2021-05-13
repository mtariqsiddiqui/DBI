window.onload = function() {
    console.log('Window loaded.');
    var entity = new EntityDocument();
    entity.retreiveRecord();
}

class EntityDocument {
    constructor(__id) {
        this._id = __id;
        this.records = [];
    }

    createRecord() {
        let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
        EntityDocument.backendHandler("POST", url);
    }

    retreiveRecord(__id) {
        if(__id === undefined) {
            let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[1];
            this.records = EntityDocument.backendHandler("GET", url);
        }
        else {
            let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0] + "?eid=";
            url = url + __id;
            this.records = EntityDocument.backendHandler("GET", url);
        }
    }

    updateRecord() {
        let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
        EntityDocument.backendHandler("PATCH", url);
    }

    deleteRecord() {
        let url = document.getElementById("api_url").value + document.getElementById("entity_container").value.split(",")[0];
        EntityDocument.backendHandler("DELETE", url);
    }

    static backendHandler(method, url) {
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
                console.log(xhr.responseText);
                if(method === "GET"){
                    EntityDocument.populateTableWithData(JSON.parse(xhr.responseText));
                } else {
                    // retreiveRecord();
                }
            } else { // Failure
                console.log(this.status);
            }
        };
        xhr.send(EntityDocument.prepareDataForSubmission());
    }

    static prepareDataForSubmission() {
        let _entity = {e : {}};
        document.querySelectorAll("input.form-control").forEach((el) => { _entity["e"][el.id] = el.value; });
        return JSON.stringify(_entity);
    }

    static populateFormWithData() {

    }

    static populateTableWithData(jRec) {
        const tbodyRef = document.getElementById('entity_table').getElementsByTagName('tbody')[0];
        jRec.forEach((r) => {
            const newRow = tbodyRef.insertRow(); // create row for each iteration
            Object.keys(r).forEach((k) => {
                const newCell = newRow.insertCell();
                const cellText = document.createTextNode(r[k]);
                newCell.appendChild(cellText);
            });
            const newCell = newRow.insertCell();
            const delButton =  document.createElement("button");
            const edtButton =  document.createElement("button");
            delButton.setAttribute('class', 'btn btn-outline-danger btn-sm');
            edtButton.setAttribute('class', 'btn btn-outline-warning btn-sm');
            delButton.innerHTML = 'Delete';
            edtButton.innerHTML = 'Edit';
            newCell.appendChild(edtButton);
            newCell.appendChild(document.createTextNode(" "));
            newCell.appendChild(delButton);
        });
    }
}