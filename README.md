## Typst templates

This repository contains templates for [Typst](https://github.com/typst/typst) paper and beamer documents. It implements mathematical blocks (definition, theorem, proof, etc.), pseudo-code blocks, and is easily extensible and customizable. Feel free to use it and to contribute!

### Usage
Clone it in
```bash
{data-dir}/typst/packages/local
```
where `{data-dir}` is 
- `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows


Then, in your document, add
```
#import "@local/{beamer, paper}:1.0.0": *
```