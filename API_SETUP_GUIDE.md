# API Setup Guide for Flux-Circuits

## Quick Start

The `.env` file has been created from `.env.example`. You need to configure your API keys before using the tool.

## Required Configuration

### 1. Cursor API Key (REQUIRED)

The Cursor API is used to generate C code from your ideas.

**How to get your Cursor API key:**

Since Cursor doesn't have a public API yet, you have a few options:

#### Option A: Use OpenAI API (Recommended for now)
The code is structured to work with OpenAI-compatible APIs. You can use OpenAI's API directly:

1. Go to https://platform.openai.com/api-keys
2. Create an API key
3. Edit `.env` and set:
   ```
   CURSOR_API_KEY=sk-your-openai-api-key-here
   CURSOR_API_URL=https://api.openai.com/v1
   ```

#### Option B: Use Anthropic Claude API
If you prefer Claude:

1. Go to https://console.anthropic.com/
2. Create an API key
3. You'll need to modify the code to use Anthropic's API format

#### Option C: Wait for Cursor API
Cursor is working on their API. Check their website for updates.

### 2. Flux API Key (OPTIONAL)

The Flux API is used to compile C code to hardware circuits. If not configured, the tool will use **mock mode** with simulated circuit generation.

**How to get your Flux API key:**

1. Visit https://flux.ai/ (or the actual Flux compiler provider)
2. Sign up for an API key
3. Edit `.env` and add your key

## Configuration Steps

1. Open the `.env` file in your editor:
   ```bash
   nano .env
   # or
   code .env
   ```

2. Replace `your_cursor_api_key_here` with your actual OpenAI API key

3. (Optional) Replace `your_flux_api_key_here` with your Flux API key

4. Save the file

5. Run your command:
   ```bash
   flux-circuits "parallel matrix multiplication with cache optimization" ASIC
   ```

## Testing Your Setup

After configuring your API key, test the tool:

```bash
flux-circuits "simple counter" FPGA
```

If you see authentication errors, double-check:
- Your API key is correct
- The API key hasn't expired
- You have sufficient credits/quota

## Troubleshooting

### Error: "CURSOR_API_KEY is not configured"
- Make sure you've edited the `.env` file
- Verify the API key doesn't have quotes around it
- Make sure there are no extra spaces

### Error: "Cursor API authentication failed"
- Your API key might be invalid or expired
- Check your API credits/quota
- Verify you're using the correct API URL

### Flux API Warnings
If you see "⚠️ FLUX_API_KEY is not configured", the tool will use mock mode. This is normal if you don't have a Flux API key yet.

## Need Help?

- Check the README.md for more information
- Review the code in `src/cursor-client.ts` and `src/flux-client.ts`
- Make sure all dependencies are installed: `npm install`
