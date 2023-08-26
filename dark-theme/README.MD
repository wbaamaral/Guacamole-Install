
To create your branded extension

1. Modify the contained css and other logo files to suit (pay attention to the various logo file resolutions used.)
2. Install the Java JDK: `sudo apt update && sudo apt install default-jdk`
3. From inside the dark-theme dir, run `jar cfmv ../branding.jar META-INF/MANIFEST.MF guac-manifest.json css images translations META-INF`
5. `cd..`
6. `sudo mv branding.jar /etc/guacamole/extensions`
7. `sudo chmod 664 /etc/guacamole/extensions/branding.jar`
8. `sudo systemctl restart guacd && sudo systemctl restart tomcat9`


