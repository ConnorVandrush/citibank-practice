import bcrypt

from app.repositories.user_repository import get_user_by_email


class AuthenticationError(Exception):
    """Raised when authentication fails."""
    pass


def authenticate_user(email: str, password: str) -> dict:
    """
    Authenticate a user using their email and password.

    Returns:
        User information if authentication succeeds.

    Raises:
        AuthenticationError if the credentials are invalid.
    """

    user = get_user_by_email(email)

    # Do not reveal whether the email exists.
    if user is None:
        raise AuthenticationError("Invalid email or password")

    password_valid = bcrypt.checkpw(
        password.encode("utf-8"),
        user["password_hash"].encode("utf-8"),
    )

    if not password_valid:
        raise AuthenticationError("Invalid email or password")

    return user

