from setuptools import find_packages, setup, Extension


with open('requirements/build.txt') as f:
    setup_requirements = f.read().splitlines()

setup(
    packages=find_packages("src"),
    setup_requires=setup_requirements,
    package_dir={"": "src"},
    ext_modules=[
        Extension(
            'maze.generation.algorithm',
            sources=['src/generation/algorithm.pyx'],
        ),
    ],
)