# Package Rename Config

How to configure and rename the package (App ID) for your Flutter project.

* Open the `package_rename_config.yaml` file located in the dev directory of your project.
* Change the value of `package_name` to the new desired package name. Example:

  ```yaml
  package_name: com.fdelux.fsdademo
  ```

* Save the changes to the `package_rename_config.yaml` file.
* Run the following command to execute the package rename inside target application directory:

  ```bash
  dart run package_rename --path="dev/package_rename_config.yaml"
  ```

