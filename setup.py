from setuptools import setup, find_packages

with open('README.md') as f:
    long_description = f.read()

setup(name='lookml-linter',
      version='2.0.5',
      description='LookML linter tool. Fork from https://github.com/ww-tech/lookml-tools.',
      url='https://github.com/rthoyer/lookml-linter',
      author='Romain Thoyer',
      author_email='romain.thoyer@govirtuo.com',
      long_description=long_description,
      long_description_content_type='text/markdown',
      license='Apache 2.0',
      packages=find_packages(),
      zip_safe=False,
      classifiers=[
        "Programming Language :: Python :: 3.7",
        "Operating System :: OS Independent"
      ],
      project_urls={
        'Documentation': 'https://ww-tech.github.io/lookml-tools/',
        'Source': 'https://github.com/rthoyer/lookml-linter',
    })
