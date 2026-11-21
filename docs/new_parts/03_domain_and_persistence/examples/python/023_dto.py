from dataclasses import dataclass
@dataclass(frozen=True)
class AccountDto:
    id: int
    cents: int
def export(account):
    return AccountDto(account.id, account.cents)
