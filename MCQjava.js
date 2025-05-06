document.getElementById("process-button").addEventListener("click", function () {
  const fileInput = document.getElementById("file-input");
  if (!fileInput.files.length) {
    alert("Por favor, selecciona un archivo.");
    return;
  }

  const file = fileInput.files[0];
  const reader = new FileReader();

  reader.onload = function (event) {
    const data = Papa.parse(event.target.result, { header: true });
    const processedData = processMCQData(data.data);
    document.getElementById("output").textContent = JSON.stringify(processedData, null, 2);
  };

  reader.readAsText(file);
});

function processMCQData(data) {
  // Paso 1: Calcular secuencias
  data.forEach(row => {
    row.SmlSeq = calculateSequence(row, ["MCQ13", "MCQ20", "MCQ26", "MCQ22", "MCQ3", "MCQ18", "MCQ5", "MCQ7", "MCQ11"], [1, 2, 4, 8, 16, 32, 64, 128, 256]);
    row.MedSeq = calculateSequence(row, ["MCQ1", "MCQ6", "MCQ24", "MCQ16", "MCQ10", "MCQ21", "MCQ14", "MCQ8", "MCQ27"], [1, 2, 4, 8, 16, 32, 64, 128, 256]);
    row.LrgSeq = calculateSequence(row, ["MCQ9", "MCQ17", "MCQ12", "MCQ15", "MCQ2", "MCQ25", "MCQ23", "MCQ19", "MCQ4"], [1, 2, 4, 8, 16, 32, 64, 128, 256]);
  });

  // Paso 2: Filtrar datos y calcular k_geo
  const filteredData = data.filter(row => row.SmlCon >= 75 && row.MedCon >= 75 && row.LrgCon >= 75);
  filteredData.forEach(row => {
    row.k_geo = Math.pow(row.SmlK * row.MedK * row.LrgK, 1 / 3);
    row.log10_k_geo = Math.log10(row.k_geo);
  });

  return filteredData;
}

function calculateSequence(row, fields, weights) {
  return fields.reduce((sum, field, index) => sum + (parseInt(row[field] || 0) * weights[index]), 0) - 510;
}
