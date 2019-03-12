import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="biobb_wf_mutations",
    version="0.0.6",
    author="Biobb developers",
    author_email="pau.andrio@bsc.es",
    description="Lysozyme + Mutations workflow built using BioBB Based on the official Gromacs tutorial: http://www.mdtutorials.com/gmx/lysozyme/01_pdb2gmx.html",
    long_description=long_description,
    long_description_content_type="text/markdown",
    keywords="Bioinformatics Workflows BioExcel Compatibility",
    url="https://github.com/bioexcel/biobb_md",
    project_urls={
        "Documentation": "http://biobb_wf_mutations.readthedocs.io/en/latest/",
        "Bioexcel": "https://bioexcel.eu/"
    },
    packages=setuptools.find_packages(exclude=['docs', 'test',]),
    include_package_data=True,
    install_requires=['biobb_common>=0.1.2', 'biobb_io>=0.1.4', 'biobb_model>=0.1.5', 'biobb_md>=0.1.5', 'biobb_adapters>=0.1.4'],
    python_requires='>=3',
    classifiers=(
        "Development Status :: 3 - Alpha",
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: POSIX",
    ),
)
