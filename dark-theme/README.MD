
### To develop and refine your own branded extension, experiment with a browser in developer mode ###

1. Install the Java JDK: `sudo apt update && sudo apt install default-jdk`
2. Modify the contained css & guac-manifest.json file template according to your own theme colour settings and logo file names.
3. To build the changed branding.jar extension, from inside the dark-theme directory run `jar cfmv ../branding.jar META-INF/MANIFEST.MF guac-manifest.json css images translations META-INF && cd..`
4. `sudo mv branding.jar /etc/guacamole/extensions` # moves the newly built .jar file over to Guacamole 
5. `sudo chmod 664 /etc/guacamole/extensions/branding.jar` # sets the correct Guacamole permissions 
6. `sudo systemctl restart guacd && sudo systemctl restart tomcat9` # bounces Guacamole to re-load the new extension
7. You may need to clear the browser cache to see all your changes reflected correctly.


### Hints: ###
  - Pay attention to logo pixel resolutions used, particularly the "smallIcon" value in guac-manifest.json. (This value relates to the browser tab favicon, so it must be something around 64x64 pixels)
  - You may need to experiment with the the css height and width values under `.login-ui .login-dialog .logo` to fit your particular logo dimensions properly within the dialog box. A little Googling around various css parameters here may help. There's a gazillion css options available here and this template is just starting point.
  - To make the login dialog box larger, in the css under `.login-ui .login-dialog` experiment with adding a `max-width: 4in;` or similar
  - The value given to "Name:" in MANIFEST.MF must match the .jar file name used in the above build command in step 3.
  - Do not change any directory structure or file names. (Company name references and logos names/paths can be changed)
    - Beware when changing company references and logos paths: Be aware that in the css, an example path to logo files is `app/ext/[insert "namespace:" value given in guac-manifest.json here]/images/logo.png`