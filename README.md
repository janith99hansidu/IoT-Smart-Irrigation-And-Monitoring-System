# 🌾 Smart Agriculture System – EC6020

An **IoT-enabled solution** designed to automate and optimize irrigation in agriculture using real-time environmental monitoring and cloud-based remote control.

---

## 👩‍💻 Team Members

| Index Number | Name |
|--------------|------|
| 2021/E/183   | Y.A.D.J.H. Yapa |
| 2021/E/075   | K.J.M.U.G.S.E. Jayasinghe |
| 2021/E/091   | M.A.D.A. Kaushalya |
| 2021/E/058   | J.M.K.P. Jayasingha |

---

## 🔍 Problem Statement

Traditional agriculture faces issues such as:

- Inefficient water usage.
- Lack of real-time environmental monitoring.
- Over-reliance on manual irrigation.

These factors contribute to poor crop health, lower yields, and significant resource wastage.

---

## 💡 Proposed Solution

Our Smart Agriculture System addresses these problems through:

1. **Soil Moisture Monitoring** – Automatically controls irrigation based on real-time soil data.
2. **Environmental Sensing** – Uses DHT11 to collect temperature and humidity readings.
3. **Cloud Connectivity** – Sends data to a cloud platform for **remote access and control**.
4. **Automated Notifications** – Alerts users when conditions are outside safe limits.
5. **Manual & Auto Modes** – Offers flexibility to override automatic control if needed.
6. **Predictive Insights** – Long-term environmental data helps forecast irrigation needs using web APIs.

---

## ✨ Key Features

- ✅ Automated irrigation based on soil moisture levels.
- 🌡️ Real-time temperature and humidity tracking.
- 🖥️ Live dashboard and app for monitoring and control.
- 🔔 Alert system for dry soil/extreme weather.
- 🔁 Manual and auto watering modes.
- 📊 Predictive analytics to prepare for changing conditions.

---

## 🔩 Hardware Components

| Component              | Description |
|------------------------|-------------|
| **NodeMCU ESP8266**    | Central Wi-Fi-enabled controller |
| **Soil Moisture Sensor** | Measures soil moisture content |
| **DHT11 Sensor**       | Tracks temperature and humidity |
| **Relay Module**       | Controls the water pump |
| **Water Pump**         | Irrigates crops based on control logic |
| **Connecting Wires**   | For circuit integration |

---

## 📡 Communication & Protocols

- **MQTT** – Efficient, lightweight real-time data communication.
- **HTTP/REST APIs** – For cloud interactions.
- **Firebase** – For remote monitoring, control, and alerting.
- **UI** – Mobile app and web dashboard for control and visualization.

---

## 🧠 System Architecture

![System Architecture](https://github.com/BuddhiniNavoda/smart-medical-reminder-box-EC6020/blob/main/Block_Diagram/Architechture_new.png?raw=true)  
> *Schematic: Sensors → NodeMCU → Relay → Water Pump; cloud communication via Wi-Fi*

---

## 📐 Circuit Design

- DHT11 connected to GPIO **D4**
- Soil Moisture Sensor connected to **A0**
- Relay connected to GPIO **D2**
- Controlled by **5V Power Supply**

---

## 🖼️ App Interface & Features

### 🌐 Live Monitoring

- Real-time circular indicators for:
  - Temperature
  - Humidity
  - Soil Moisture

### ⚙️ Smart Control Modes

- **Auto Mode**: Waters plants when moisture drops below threshold.
- **Manual Mode**: Control water pump manually via app button.
- **Wi-Fi Toggle**: Securely connect/disconnect the device.

---

## 💸 Budget

| Component | Quantity | Unit Price (LKR) | Total (LKR) |
|----------|----------|------------------|-------------|
| NodeMCU ESP8266 | 1 | 1020.00 | 1020.00 |
| Soil Moisture Sensor | 1 | 360.00 | 360.00 |
| Water Pump | 1 | 1310.00 | 1310.00 |
| Relay Module | 1 | 155.00 | 155.00 |
| DHT11 Sensor | 1 | 380.00 | 380.00 |
| Connecting Wires | 10 | 30.00 | 300.00 |
| **Total** | – | – | **3525.00 LKR** |

---

## 🗓️ Project Timeline

- ✅ Week 1–2: Component research and circuit planning  
- ✅ Week 3–4: Hardware procurement and initial assembly  
- 🔧 Week 5–6: Code development and testing  
- 🔄 Week 7–8: Cloud sync, UI integration  
- 📦 Final Week: Testing, debugging, and documentation

---

## 🔗 GitHub Repository

📁 [Project Repository](https://github.com/janith99hansidu/EC6020-Smart-Agriculture-Project)

---

## 🙌 Thank You!

Let us know if you have any feedback or suggestions! We are open to collaboration and enhancements.

---

Would you like this version exported as a `README.md` file ready to upload to GitHub? I can also zip it along with assets (images, diagrams, etc.) if needed.Perfect! Here's your **GitHub `README.md`** for the **Smart Agriculture Project (EC6020)** — with all sections, images, and details from both the presentation and project proposal PDF integrated and organized in a polished format:

---

# 🌾 Smart Agriculture System – EC6020

An **IoT-enabled solution** designed to automate and optimize irrigation in agriculture using real-time environmental monitoring and cloud-based remote control.

---

## 👩‍💻 Team Members

| Index Number | Name |
|--------------|------|
| 2021/E/183   | Y.A.D.J.H. Yapa |
| 2021/E/075   | K.J.M.U.G.S.E. Jayasinghe |
| 2021/E/091   | M.A.D.A. Kaushalya |
| 2021/E/058   | J.M.K.P. Jayasingha |

---

## 🔍 Problem Statement

Traditional agriculture faces issues such as:

- Inefficient water usage.
- Lack of real-time environmental monitoring.
- Over-reliance on manual irrigation.

These factors contribute to poor crop health, lower yields, and significant resource wastage.

---

## 💡 Proposed Solution

Our Smart Agriculture System addresses these problems through:

1. **Soil Moisture Monitoring** – Automatically controls irrigation based on real-time soil data.
2. **Environmental Sensing** – Uses DHT11 to collect temperature and humidity readings.
3. **Cloud Connectivity** – Sends data to a cloud platform for **remote access and control**.
4. **Automated Notifications** – Alerts users when conditions are outside safe limits.
5. **Manual & Auto Modes** – Offers flexibility to override automatic control if needed.
6. **Predictive Insights** – Long-term environmental data helps forecast irrigation needs using web APIs.

---

## ✨ Key Features

- ✅ Automated irrigation based on soil moisture levels.
- 🌡️ Real-time temperature and humidity tracking.
- 🖥️ Live dashboard and app for monitoring and control.
- 🔔 Alert system for dry soil/extreme weather.
- 🔁 Manual and auto watering modes.
- 📊 Predictive analytics to prepare for changing conditions.

---

## 🔩 Hardware Components

| Component              | Description |
|------------------------|-------------|
| **NodeMCU ESP8266**    | Central Wi-Fi-enabled controller |
| **Soil Moisture Sensor** | Measures soil moisture content |
| **DHT11 Sensor**       | Tracks temperature and humidity |
| **Relay Module**       | Controls the water pump |
| **Water Pump**         | Irrigates crops based on control logic |
| **Connecting Wires**   | For circuit integration |

---

## 📡 Communication & Protocols

- **MQTT** – Efficient, lightweight real-time data communication.
- **HTTP/REST APIs** – For cloud interactions.
- **Firebase** – For remote monitoring, control, and alerting.
- **UI** – Mobile app and web dashboard for control and visualization.

---

## 🧠 System Architecture

![System Architecture](https://github.com/BuddhiniNavoda/smart-medical-reminder-box-EC6020/blob/main/Block_Diagram/Architechture_new.png?raw=true)  
> *Schematic: Sensors → NodeMCU → Relay → Water Pump; cloud communication via Wi-Fi*

---

## 📐 Circuit Design

- DHT11 connected to GPIO **D4**
- Soil Moisture Sensor connected to **A0**
- Relay connected to GPIO **D2**
- Controlled by **5V Power Supply**

---

## 🖼️ App Interface & Features

### 🌐 Live Monitoring

- Real-time circular indicators for:
  - Temperature
  - Humidity
  - Soil Moisture

### ⚙️ Smart Control Modes

- **Auto Mode**: Waters plants when moisture drops below threshold.
- **Manual Mode**: Control water pump manually via app button.
- **Wi-Fi Toggle**: Securely connect/disconnect the device.

---

## 💸 Budget

| Component | Quantity | Unit Price (LKR) | Total (LKR) |
|----------|----------|------------------|-------------|
| NodeMCU ESP8266 | 1 | 1020.00 | 1020.00 |
| Soil Moisture Sensor | 1 | 360.00 | 360.00 |
| Water Pump | 1 | 1310.00 | 1310.00 |
| Relay Module | 1 | 155.00 | 155.00 |
| DHT11 Sensor | 1 | 380.00 | 380.00 |
| Connecting Wires | 10 | 30.00 | 300.00 |
| **Total** | – | – | **3525.00 LKR** |

---

## 🗓️ Project Timeline

- ✅ Week 1–2: Component research and circuit planning  
- ✅ Week 3–4: Hardware procurement and initial assembly  
- 🔧 Week 5–6: Code development and testing  
- 🔄 Week 7–8: Cloud sync, UI integration  
- 📦 Final Week: Testing, debugging, and documentation

---

## 🔗 GitHub Repository

📁 [Project Repository](https://github.com/janith99hansidu/EC6020-Smart-Agriculture-Project)
