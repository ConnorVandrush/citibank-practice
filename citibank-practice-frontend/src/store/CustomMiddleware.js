import { chat_emitters } from "../socket/emitters/chat_emitters.js";

export const CustomeMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    if (!initialized) {
      initialized = true;
    }
    chat_emitters(store, action);

    return next(action);
  };
};
