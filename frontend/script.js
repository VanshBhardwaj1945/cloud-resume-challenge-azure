window.addEventListener("DOMContentLoaded", () => {
  getVisitCount();
});

const functionAPIURL = "https://page-counter-dtc9cgcmerbvaxg2.eastus-01.azurewebsites.net/api/getResumeCounter?code=t563y_QzPRjG1NETW3H5OhqSmNK55bifV-f3ZW4aCTcxAzFul_D6OQ=="
const functionAPI = "http://localhost:7071/api/getResumeCounter";

const getVisitCount = async () => {
  const counterEl = document.getElementById("counter");
  try {
    const res = await fetch(functionAPIURL);
    if (!res.ok) throw new Error(`Function returned ${res.status}`);
    const data = await res.json();

    console.log("Website called function API.", data);

    counterEl.innerText = data.count ?? "0";
  } catch (err) {
    console.error("getVisitCount error:", err);
    counterEl.innerText = "—"; 
  }
};
