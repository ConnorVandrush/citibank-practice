export const CustomeMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    if (!initialized) {
      initialized = true;
    }
    return next(action);
  };
};
