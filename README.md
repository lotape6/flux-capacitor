# flux-capacitor
Collection of useful tools and stuff to enable time traveling on your terminal. It's based on the [Modern Unix collection of alternative commands](https://github.com/ibraheemdev/modern-unix)

<p align="center">
  <img src="resources/flux.gif" alt="animated" />
</p>

At the beginning of *setup.god* script you can select the tools you want to be installed by setting to *"true"* the corresponfing variable in the *enable* list. It will try to install selected tools with the corresponding package manager or downloading the corresponding release binaries from official repository (if provided).

Currently tested only in Ubuntu 18.04 amd64 based computer with zsh as default shell, none the less I tried to make the script as flexible as possible. It tries to install packages with *apk*, *apt-get* *dnf*, *zypper* or *pacman*. If finally downloads the binaries from the official release, it detects the hardware architecture and download the corresponding binaries if available.


