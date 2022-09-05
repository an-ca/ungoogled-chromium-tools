# Install Widevine for ungoogled-chromium from Google Chrome

Based on script by [dkebler](https://gist.github.com/dkebler/b90ca57ac481a428dcb6cbbd1e36553d).

I've modified the script so that it looks for the "compatible" version
– i.e. same major digit – in Google's repo Packages file instead of trying to
download the exact same version as ungoogled-chromium's version – which
repeatedly failed with the versions I was using with the original script.
