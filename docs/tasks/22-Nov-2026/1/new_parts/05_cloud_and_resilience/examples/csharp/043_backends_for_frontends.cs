interface ICatalog { int Price(); int Shipping(); }
static int Mobile(ICatalog c) => c.Price();
static int Web(ICatalog c) => c.Price() + c.Shipping();
