class Account {
  Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
  });

  final String id;
  final String name;
  final String accountType;
  final double balance;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        accountType: json['account_type'] as String,
        balance: (json['balance'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account_type': accountType,
        'balance': balance,
      };

  Account copyWith({
    String? id,
    String? name,
    String? accountType,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
    );
  }

  // Helper method to get account type display name
  String get accountTypeDisplayName {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'checking':
        return 'Checking Account';
      case 'credit':
        return 'Credit Card';
      case 'investment':
        return 'Investment Account';
      default:
        return accountType;
    }
  }

  // Helper method to get masked account number
  String get maskedNumber {
    // Generate a simple masked number based on account type
    switch (accountType.toLowerCase()) {
      case 'credit':
        return '**** **** **** ${id.substring(id.length - 4).padLeft(4, '0')}';
      default:
        return '**** ${id.substring(id.length - 4).padLeft(4, '0')}';
    }
  }
}
