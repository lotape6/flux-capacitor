# Flux Capacitor Cheatsheet

This directory contains a LaTeX-based cheatsheet for the Flux Capacitor tool, inspired by the excellent [ShellCheatsheet](https://github.com/lotape6/ShellCheatsheet) design.

## 📋 What's Included

The cheatsheet covers:

- **Core Commands**: `flux connect`, `flux launch`, `flux clean`, `flux help`
- **Advanced Usage**: Session management, environment loading, command execution
- **Shell Completion**: Bash, Zsh, and Fish completion features
- **Configuration**: Config files and tmux integration
- **Examples & Workflows**: Real-world usage patterns
- **Installation**: Setup and prerequisites

## 🔧 Prerequisites

To build the PDF, you need:

### Required
- **pdflatex** (from TeXLive or MiKTeX)
- **tikz** package (for keystroke styling)
- **tcolorbox** package (for colored boxes)

### Optional but Recommended
- **fontawesome** package (for icons)
- **raleway** font package (for typography)
- **minted** package (for syntax highlighting)

### Installation on Ubuntu/Debian
```bash
sudo apt update
sudo apt install texlive-latex-base texlive-latex-extra texlive-pictures texlive-fonts-extra
```

### Installation on macOS
```bash
brew install mactex
```

### Installation on other systems
Install TeXLive from [https://www.tug.org/texlive/](https://www.tug.org/texlive/)

## 🚀 Building the Cheatsheet

### Quick Build
```bash
cd docs/cheatsheet
make
```

### Check Prerequisites
```bash
make check
```

### Build and Preview
```bash
make preview
```

### Clean Build
```bash
make clean
make all
```

## 📁 File Structure

```
docs/cheatsheet/
├── Makefile                           # Build system
├── README.md                          # This file
├── src/
│   ├── main.tex                       # Main cheatsheet document
│   ├── flux-cheatsheet-template.tex   # Styling and layout template
│   └── images/                        # Images (if any)
├── build/                             # Temporary build files (auto-created)
└── flux-capacitor-cheatsheet.pdf     # Final output
```

## 🎨 Customization

### Colors
The cheatsheet uses a custom color scheme defined in `flux-cheatsheet-template.tex`:

- **fluxblue** (`#1E90FF`) - Primary accent color
- **fluxgreen** (`#32CD32`) - Success/tips color  
- **alert** (`#CD5C5C`) - Warning/error color
- **w3schools** (`#4CAF50`) - Pros/positive color
- **yellow** (`#aabb44`) - Tips/neutral color

### Layout
- **3-column landscape layout** for maximum information density
- **Colored boxes** for different content types
- **Keyboard shortcuts** with styled key representations
- **Code blocks** with syntax highlighting
- **Command descriptions** with consistent formatting

### Adding Content

1. **New sections**: Add to `main.tex` using `\section{Title}`
2. **New textboxes**: Use `\begin{textbox}{Title}...\end{textbox}`
3. **Commands**: Use `\mycommand{command}{description}`
4. **Keyboard shortcuts**: Use `\keystroke{key}` or `\keystroke{Ctrl} + \keystroke{C}`
5. **Code blocks**: Use the `codebox` environment
6. **Colors**: Use `\green{text}`, `\red{text}`, `\yellow{text}`, `\blue{text}`

## 🛠️ Troubleshooting

### Common Issues

**"pdflatex: command not found"**
- Install TeXLive or MiKTeX

**"tikz.sty not found"**
- Install `texlive-pictures` package

**"tcolorbox.sty not found"**  
- Install `texlive-latex-extra` package

**Build fails with font errors**
- Install `texlive-fonts-extra` package
- Some fonts are optional and can be commented out

**"minted" errors**
- Install Python and pygments: `pip install pygments`
- Or remove minted usage from template

### Build Output
The final PDF will be created as `flux-capacitor-cheatsheet.pdf` in the current directory.

## 📜 License

This cheatsheet follows the same license as the Flux Capacitor project. The LaTeX template is inspired by and adapted from the [ShellCheatsheet](https://github.com/lotape6/ShellCheatsheet) project.

## 🤝 Contributing

To improve the cheatsheet:

1. Edit the content in `src/main.tex`
2. Modify styling in `src/flux-cheatsheet-template.tex`  
3. Test with `make rebuild`
4. Submit a pull request

Feel free to add new sections, improve examples, or enhance the visual design!