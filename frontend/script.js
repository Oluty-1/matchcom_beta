const API_URL = 'https://<your-api-id>.execute-api.<your-region>.amazonaws.com/prod';

function calculateCompatibility() {
  const name1 = document.getElementById('name1').value.trim();
  const age1 = parseInt(document.getElementById('age1').value);
  const name2 = document.getElementById('name2').value.trim();
  const age2 = parseInt(document.getElementById('age2').value);

  if (!name1 || !name2 || isNaN(age1) || isNaN(age2) || age1 <= 0 || age2 <= 0) {
    showResult('Please enter valid names and ages.');
    return;
  }

  // Love Equation: (name1.length * name2.length) / (age1 + age2) * 50
  let score = (name1.length * name2.length) / (age1 + age2) * 50;

  // Soulmate bonus: +25% if names start with the same letter
  if (name1[0].toLowerCase() === name2[0].toLowerCase()) {
    score += 25;
  }

  // Round to 2 decimal places
  score = Math.min(score, 100).toFixed(2);

  // Send to backend
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
    } else {
      showResult(`Error: ${data.error}`);
    }
  } catch (error) {
    showResult('Failed to connect to the server.');
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