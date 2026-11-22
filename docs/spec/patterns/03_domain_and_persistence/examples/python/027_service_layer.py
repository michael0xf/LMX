def checkout(db, repository, account_id, amount):
    def body():
        account = repository.load(account_id)
        account.debit(amount)
        repository.save(account)
    db.atomic(body)
