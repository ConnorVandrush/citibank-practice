import { socket } from "../socket/socket.js";
import { sendChatMessage } from "../../store/EmployeeSlice.js";

export default async function EmployeeSlice(store, action) {
  try {
    if (action.type === sendChatMessage.type) {
      socket.emit("send_message", action.payload);
    }
  } catch (error) {
    console.error("EmployeeSliceEmitters:", error);
  }
}
