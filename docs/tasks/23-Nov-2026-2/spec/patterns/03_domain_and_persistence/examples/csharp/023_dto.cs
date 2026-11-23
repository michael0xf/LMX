public sealed record AccountDto(int Id,int Cents);
public sealed record Account(int Id,int Cents,string Token);
public static class Export {
    public static AccountDto Dto(Account account) => new(account.Id,account.Cents);
}
