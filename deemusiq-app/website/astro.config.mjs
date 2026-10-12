// @ts-check
import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";
import react from "@astrojs/react";
import mdx from "@astrojs/mdx";
import rehypeSlug from "rehype-slug";
import rehypeAutolinkHeadings from "rehype-autolink-headings";
import pagefind from "astro-pagefind";
import { unified } from "@astrojs/markdown-remark";

// https://astro.build/config
export default defineConfig({
  // v7 defaults to 'jsx' whitespace stripping; keep HTML-aware compression
  compressHTML: true,
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    // v7 defaults to Sätteri; stay on unified so these rehype plugins apply
    processor: unified({
      gfm: true,
      rehypePlugins: [
        [rehypeSlug, {}],
        [
          rehypeAutolinkHeadings,
          {
            behavior: "wrap", // Adds the link at the end of the heading
            properties: {
              className: ["heading-link"], // Add a class for styling
              "aria-hidden": "true",
            },
            content: {
              // Optional: Use an SVG icon or text for the link
              type: "element",
              tagName: "span",
              properties: { className: ["icon", "icon-link"] },
              children: [{ type: "text", value: " #" }],
            },
          },
        ],
      ],
    }),
    syntaxHighlight: "shiki",
  },
  integrations: [react(), mdx(), pagefind()],
  redirects: {
    "/docs": "/docs/get-started/introduction",
    "/docs/get-started": "/docs/get-started/introduction",
  },
});
