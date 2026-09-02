def test_package_is_importable() -> None:
    """The src layout only works if the package is installed into the venv."""
    import jul_ia

    assert jul_ia.__name__ == "jul_ia"
