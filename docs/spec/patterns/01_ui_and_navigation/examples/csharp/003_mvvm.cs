using System.ComponentModel;
static class Example {
    sealed class ViewModel : INotifyPropertyChanged {
        int count;
        public event PropertyChangedEventHandler? PropertyChanged;
        public int Doubled => count * 2;
        public void Set(int value) {
            count = value;
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Doubled)));
        }
    }
    public static int Demo() {
        var vm = new ViewModel(); int shown = 0;
        vm.PropertyChanged += (_, e) => {
            if (e.PropertyName == nameof(ViewModel.Doubled)) shown = vm.Doubled;
        };
        vm.Set(6);
        return shown;
    }
}
