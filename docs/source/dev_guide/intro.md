# Developer Introduction

Some definitions to get started:

- **Class**: A blueprint for creating objects. A class defines the properties and methods that an object will have.
- **Abstract class**: A class that is not intended to be instantiated, but is instead intended to the base class for other classes. Abstract classes are used to define a common interface for a group of classes.
- **Function**: A block of code that can be called from elsewhere in the program. Functions can take arguments and return values. They can either be standalone or part of a class, if they are part of a class functions do not need to be called with an instance of the class, simply the class itself.
- **Method**: A function that is part of a class. Methods are called with an instance of the class, and can access the instance's properties and other methods.
- **Property**: A value that is part of an object. Properties are accessed and modified using dot notation, e.g. `object.property = value`.

In the description of each class, the following information is provided:
- **Purpose**: A brief description of what the class or function does and why.
- **Properties**: A list of the properties that the class has, along with a brief description of each including its type and default value.
- **Functions**: A list of the functions that the class has, along with a brief description of each including its arguments and return value and why it exists.
- **Methods**: A list of the methods that the class has, along with a brief description of each including its arguments and return value and why it exists.
- **Potential Future Changes**: A list of potential changes that could be made to the class in the future.
If any of the above sections are not present, it is because the class does not have any properties, functions, methods, or potential future changes.

---
**Important**

All the input variables are technically not independent of units. Therefore, for the user to know if they are using the correct units, they must use the `units` class. Any number that is input into a function must be multiplied by the unit, for example, 80 keV would be input as `80*units.keV`. With this in mind, all input variables will be consistent with what the function expects.

---

## What is the Developer Guide?

The developer guide is a collection of documents that provide information about every class and function in the project. It is intended to be a reference for developers who are working on the project, and to provide a high-level overview of the project's architecture and design along with the reasoning behind it.

## How to get started

To contribute to this project, the first step is to fork the repository and clone it to your local machine. The repository is located at [lborophysics/DECTSim](https://github.com/lborophysics/DECTSim). Once you have a fork on your GitHub account, you can clone the repository to your local machine using the following command:

```bash
git clone # Your forked repository URL
```

Once you have cloned the repository, you can create a new branch to work on using the following command:

```bash
git checkout -b # Your branch name
```

After you have made your changes, make sure you have added and committed them. You can then push your changes to your forked repository. Once you are sure that your changes are ready to be merged into the main repository, you can create a pull request. This will allow the maintainers of the project to review your changes and merge them into the main repository. 

In this pull request, you should provide a brief description of the changes you have made, this can be a list of bullet points or a more detailed explanation. If you have modified any existing code, you must provide a justification for the changes, your pull request will not be accepted if you do not provide a justification. 

When this pull request is opened, the tests will be run automatically to ensure that your changes do not break any existing functionality, and then coverage will be calculated to ensure that your changes are well tested. If all of this is successful, and the maintainers are happy with your changes, they will be merged into the main repository.

## The review process

When you open a pull request, the maintainers of the project will review your changes. They will check that your changes are well tested, that they do not break any existing functionality, and that they are well documented. If your changes do not meet these criteria, the maintainers will provide feedback on how you can improve them. You should then make the necessary changes and push them to your forked repository. Once you have done this, you can request another review from the maintainers.

## Contributing Guidlines

Below are some guidelines to ensure smooth collaboration and maintain the quality of the codebase:

1. **Consistency**: Follow the existing coding style and conventions. The code uses snake_case for all names, if you are adding new code, please follow this convention, or justify why you are not following it. Consistent code style makes the codebase easier to read and maintain. Please use the folder structure and naming conventions that are already in place for any new files you add.

2. **Extendability**: When writing functions and classes, consider future extensibility. Design them in a way that allows for easy extension and modification, promoting the longevity and flexibility of the codebase.

3. **Testing**: Testing is at the heart of our program. We rely on comprehensive testing to ensure reliability and stability. We welcome pull requests, but they will only be accepted once the new code has been thoroughly tested and meets our quality standards. Please include relevant tests along with your changes.

4. **Documentation**: Clear and comprehensive documentation is essential for understanding the program's functionality and usage. We encourage contributors to provide documentation alongside their code changes and tests. Well-documented code helps maintain readability and facilitates future development efforts.


## Creating the mex files
The mex files are created using the Coder app in MATLAB, this can be opened by typing `coder` in the MATLAB command window. Once the app is open, you can select one of three files that are ready be made into a mex file. 

The three files are: 
- `photon_attenuation.m`
- `ray_trace_many.m`
- `ray_trace.m`

The `ray_trace.m` file is not used in the code apart from tests, but should be the backup file in case you do not trust the other two files.

Once you have selected the file, click next until you come to the page to define the input types. For each of the files, there is a comment at the bottom of the file that tells gives you example code to run in the coder app. Copy this line and place it into the coder app. In the same area for each file, there is a comment that tells you what the input types should be. Take care to not ignore the `:` in the input types. Click next, check for runtime issues, and then click next again. 

Now you should be in the page to generate the code. Select the build type as `MEX`, no other options are required to be changed, but feel free to experiment with them. Click Generate, and the mex file will be created in the same directory as the file you selected.

Click next and if you have MEX generated successfully, you can close the app. The mex file is now ready to be used in the code.

If you have any issues with the mex files, please use the issues tab on the GitHub repository to ask for help or report a bug. Or otherwise, make a pull request with the changes you have made to fix the issue.