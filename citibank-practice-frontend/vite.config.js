import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],

  server: {
    proxy: {
      "/auth": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },

      "/employees": {
        target: "http://127.0.0.1:8001",
        changeOrigin: true,
      },

      "/managers": {
        target: "http://127.0.0.1:8002",
        changeOrigin: true,
      },

      "/expenses": {
        target: "http://127.0.0.1:8003",
        changeOrigin: true,
      },

      "/socket.io": {
        target: "http://127.0.0.1:8004",
        ws: true,
      },
    },
  },
});
