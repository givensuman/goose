return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            -- Snacks terminal window configuration
            require("snacks.terminal").open("opencode --port", {
              win = {
                position = "right",
                width = 50,
              },
            })
            -- vim.fn.jobstart({ "opencode", "--port" }, { detach = true })
          end,
        },
      }
      vim.o.autoread = true

      -- Keymaps
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Inline OpenCode Ask" })

      vim.keymap.set("n", "<leader>or", function()
        require("opencode").ask("Review this file for performance and bugs")
      end, { desc = "Inline OpenCode Review" })
    end,
  },

  {
    "folke/sidekick.nvim",
    dependencies = { "folke/snacks.nvim" },
    ---@type sidekick.Config
    opts = {
      nes = false, -- Disable inline suggestions via Copilot
      cli = {
        win = {
          layout = "right",
          width = 50,
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ name = "opencode" })
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close({ name = "opencode" })
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ name = "opencode", msg = "{line}" })
        end,
        mode = "n",
        desc = "Send Current Line",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ name = "opencode", msg = "{selection}" })
        end,
        mode = "x",
        desc = "Send Selection Context",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ name = "opencode", msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt({ name = "opencode" })
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
