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
    console.error('Error sending data:', error);
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
    displayRecords([]); // Fallback to empty array
  }
}

function displayRecords(records) {
  const container = document.getElementById('records-container');
  container.innerHTML = '';
  if (!Array.isArray(records) || records.length === 0) {
    container.innerHTML = '<p class="text-gray-500">No records found.</p>';
    return;
  }
  records.forEach(record => {
    const recordDiv = document.createElement('div');
    recordDiv.classList.add('p-4', 'border', 'rounded-lg', 'mb-2', 'bg-gray-50');
    recordDiv.innerHTML = `
      <p class="font-medium">${record.user1} & ${record.user2}: ${record.score}%</p>
      <div class="mt-2 space-x-2">
        <button onclick="viewRecord('${record.id}')" class="text-blue-500 hover:underline">View</button>
        <button onclick="editRecord('${record.id}')" class="text-green-500 hover:underline">Edit</button>
        <button onclick="deleteRecord('${record.id}')" class="text-red-500 hover:underline">Delete</button>
      </div>
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
    if (response.ok) {
      showDetails(record);
    } else {
      alert(`Error: ${record.error}`);
    }
  } catch (error) {
    console.error('Error fetching record:', error);
    alert('Failed to fetch record.');
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

function editRecord(id) {
  viewRecord(id).then(() => {
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
  });
}

function closeEdit() {
  document.getElementById('edit-modal').classList.add('hidden');
}

async function saveChanges() {
  const updatedData = {
    user1: document.getElementById('edit-name1').value.trim(),
    age1: parseInt(document.getElementById('edit-age1').value),
    user2: document.getElementById('edit-name2').value.trim(),
    age2: parseInt(document.getElementById('edit-age2').value),
    score: parseFloat(document.getElementById('edit-score').value)
  };

  if (!updatedData.user1 || !updatedData.user2 || isNaN(updatedData.age1) || isNaN(updatedData.age2) || isNaN(updatedData.score) || updatedData.age1 <= 0 || updatedData.age2 <= 0 || updatedData.score < 0 || updatedData.score > 100) {
    alert('Please enter valid names, ages, and score (0-100).');
    return;
  }

  try {
    const response = await fetch(`${API_URL}/compatibility/${currentRecordId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updatedData)
    });
    if (response.ok) {
      closeEdit();
      fetchRecords();
      alert('Record updated successfully.');
    } else {
      const errorData = await response.json();
      alert(`Error: ${errorData.error}`);
    }
  } catch (error) {
    console.error('Error updating record:', error);
    alert('Failed to update record.');
  }
}

function deleteRecord(id) {
  if (confirm('Are you sure you want to delete this record?')) {
    deleteRecordRequest(id);
  }
}

async function deleteRecordRequest(id) {
  try {
    const response = await fetch(`${API_URL}/compatibility/${id}`, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' }
    });
    if (response.ok) {
      closeDetails();
      fetchRecords();
      alert('Record deleted successfully.');
    } else {
      const errorData = await response.json();
      alert(`Error: ${errorData.error}`);
    }
  } catch (error) {
    console.error('Error deleting record:', error);
    alert('Failed to delete record.');
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

// Sidebar Toggle
document.getElementById('menu-toggle').addEventListener('click', () => {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.toggle('-translate-x-full');
  fetchRecords(); // Refresh records when opening
});

document.getElementById('close-sidebar').addEventListener('click', () => {
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.add('-translate-x-full');
});

window.onload = function() {
  fetchRecords();
};