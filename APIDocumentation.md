# 📘 API Documentation

## **GET /Order/{id}**

Retrieves details of a specific order by its unique identifier.

### 🔹 Path Parameters

| Parameter | Type   | Required | Description                |
| --------- | ------ | -------- | -------------------------- |
| `id`      | string | ✅ Yes    | Unique identifier of order |

### 🔹 Response Example

```Payload
{
  "type": "order_details",
  "payload": {
    "id": "evt_12345",
    "title": "Pay 181 Stock",
    "startTime": "2025-06-01T09:00:00Z",
    "endTime": "2025-06-01T17:00:00Z",
    "orderStatus": "submitted"
  },
  "meta": {
    "timestamp": "2025-05-09T15:34:00Z"
  }
}
```

### 🔹 Status Codes

| Code | Description           |
| ---- | --------------------- |
| 200  | OK - order found      |
| 404  | Not Found             |
| 500  | Internal Server Error |

---

## 🎯 Order Status Reference

| Status                 | Description                                                                                                                 |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **`submitted`**        | The order has been received by the backend but has **not yet reached the execution system**.                          |
| **`routed`**           | The order has been **forwarded to the execution system** (e.g. a trading engine or external processor).               |
| **`partially filled`** | A **portion of the order has been processed**, but it’s not complete. Common for large or staged executions.          |
| **`filled`**           | The order has been **fully processed or executed**. This is typically a terminal status.                              |
| **`cancelled`**        | The order was **cancelled before completion**, either manually or due to a system decision.                           |
| **`rejected`**         | The order was **rejected** by the system or external processor, possibly due to validation failure or business rules. |

---

## 🔁 Example Status Flow

Here’s a typical order lifecycle:

1. ✅ **`submitted`** – Client sends request to backend.
2. 📤 **`routed`** – Backend forwards request to external system.
3. 📉 **`partially filled`** – Some part of the order is fulfilled.
4. 📈 **`filled`** – Order is fully executed.
5. 🗑️ **`Cancelled`** – Order is cancelled before completion.
5. ❌ **`rejected`** – Order is rejected.
