const API_URL = 'https://r8mdux77hk.execute-api.us-east-1.amazonaws.com/prod';
let currentRecordId;

function calculateCompatibility() {
  const name1 = document.getElementById('name1').value.trim();
  const age1 = parseInt(document.getElementById('age1').value);
  const name2 = document.getElementById('name2').value.trim();
  const age2 = parseInt(document.getElementById('age2').value);

  if (!name1 || !name2 || isNaN(age1) || isNaN(age2) || age1 <= 0 || age2 <= 0) {
    showResult('Please enter valid names and ages.');
    return;
  }

  let score = (name1.length * name2.length) / (age1 + age2) * 50;
  if (name1[0].toLowerCase() === name2[0].toLowerCase()) {
    score += 25;
  }
  score = Math.min(score, 100).toFixed(2);

  sendToBackend(name1, age1, name2, age2, score);
}

async function sendToBackend(name1, age1, name2, age2, score) {
  try {
    const response = await fetch(`${API_URL}/compatibility`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user1: name1, user2: name2, age1, age2, score })
    });

    const data = await response.json();
    if (response.ok) {
      showResult(`Compatibility Score: ${data.score}%`);
      fetchRecords();
    } else {
      showResult(`Error: ${data.error}`);
    }
  } catch (error) {
    showResult('Failed to connect to the server.');
  }
}

async function fetchRecords() {
  try {
    const response = await fetch(`${API_URL}/compatibility`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    const records = await response.json();
    displayRecords(records);
  } catch (error) {
    console.error('Error fetching records:', error);
  }
}

function displayRecords(records) {
  const container = document.getElementById('records-container');
  container.innerHTML = '';
  records.forEach(record => {
    const recordDiv = document.createElement('div');
    recordDiv.classList.add('p-4', 'border', 'rounded-lg', 'mb-2');
    recordDiv.innerHTML = `
      <p>${record.user1} and ${record.user2}: ${record.score}%</p>
      <button onclick="viewRecord('${record.id}')" class="text-blue-500">View</button>
    `;
    container.appendChild(recordDiv);
  });
}

async function viewRecord(id) {
  try {
    const response = await fetch(`${API_URL}/compatibility/${id}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    const record = await response.json();
    showDetails(record);
  } catch (error) {
    console.error('Error fetching record:', error);
  }
}

function showDetails(record) {
  currentRecordId = record.id;
  document.getElementById('detail-name1').innerText = `Name 1: ${record.user1}`;
  document.getElementById('detail-age1').innerText = `Age 1: ${record.age1}`;
  document.getElementById('detail-name2').innerText = `Name 2: ${record.user2}`;
  document.getElementById('detail-age2').innerText = `Age 2: ${record.age2}`;
  document.getElementById('detail-score').innerText = `Score: ${record.score}%`;
  document.getElementById('details-modal').classList.remove('hidden');
}

function closeDetails() {
  document.getElementById('details-modal').classList.add('hidden');
}

function editRecord() {
  const name1 = document.getElementById('detail-name1').innerText.split(': ')[1];
  const age1 = document.getElementById('detail-age1').innerText.split(': ')[1];
  const name2 = document.getElementById('detail-name2').innerText.split(': ')[1];
  const age2 = document.getElementById('detail-age2').innerText.split(': ')[1];
  const score = document.getElementById('detail-score').innerText.split(': ')[1].replace('%', '');

  document.getElementById('edit-name1').value = name1;
  document.getElementById('edit-age1').value = age1;
  document.getElementById('edit-name2').value = name2;
  document.getElementById('edit-age2').value = age2;
  document.getElementById('edit-score').value = score;

  document.getElementById('edit-modal').classList.remove('hidden');
  closeDetails();
}

function closeEdit() {
  document.getElementById('edit-modal').classList.add('hidden');
}

async function saveChanges() {
  const updatedData = {
    user1: document.getElementById('edit-name1').value,
    age1: parseInt(document.getElementById('edit-age1').value),
    user2: document.getElementById('edit-name2').value,
    age2: parseInt(document.getElementById('edit-age2').value),
    score: parseFloat(document.getElementById('edit-score').value)
  };
  try {
    const response = await fetch(`${API_URL}/compatibility/${currentRecordId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updatedData)
    });
    if (response.ok) {
      closeEdit();
      fetchRecords();
    } else {
      const errorData = await response.json();
      alert(`Error: ${errorData.error}`);
    }
  } catch (error) {
    console.error('Error updating record:', error);
  }
}

function deleteRecord() {
  if (confirm('Are you sure you want to delete this record?')) {
    deleteRecordRequest(currentRecordId);
  }
}

async function deleteRecordRequest(id) {
  try {
    const response = await fetch(`${API_URL}/compatibility/${id}`, {
      method: 'DELETE'
    });
    if (response.ok) {
      closeDetails();
      fetchRecords();
    } else {
      const errorData = await response.json();
      alert(`Error: ${errorData.error}`);
    }
  } catch (error) {
    console.error('Error deleting record:', error);
  }
}

function showResult(message) {
  const overlay = document.getElementById('result-overlay');
  const resultText = document.getElementById('result-text');
  resultText.innerText = message;
  overlay.classList.remove('hidden');
}

function closeOverlay() {
  const overlay = document.getElementById('result-overlay');
  overlay.classList.add('hidden');
}

window.onload = function() {
  fetchRecords();
};