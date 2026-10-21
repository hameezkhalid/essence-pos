import '../tax/tax_engine.dart';
import 'order_models.dart';

bool _b(Map j, String k, bool d) => j[k] is bool ? j[k] as bool : d;
int _i(Map j, String k, int d) => (j[k] as num?)?.toInt() ?? d;
String _s(Map j, String k, String d) => j[k] is String ? j[k] as String : d;

/// Keys of the store-wide settings documents.
class SettingKeys {
  static const store = 'store';
  static const pricing = 'pricing';
  static const orderTypes = 'orderTypes';
  static const charges = 'charges';
  static const discounts = 'discounts';
  static const receipt = 'receipt';
  static const fbr = 'fbr';
  static const security = 'security';
  static const permissions = 'permissions';
  static const online = 'online';
}

class StoreSettings {
  const StoreSettings({
    this.name = 'Essence',
    this.tagline = 'Patisserie · Coffee · Moments',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.ntn = '',
    this.strn = '',
    this.ownerCompany = 'Mix & Match Collection',
    this.invoicePrefix = 'ESS',
    this.dayStartHour = 4,
  });
  final String name, tagline, address, phone, email, ntn, strn, ownerCompany, invoicePrefix;

  /// Sales before this hour count towards the previous business day.
  final int dayStartHour;

  Map<String, dynamic> toJson() => {
        'name': name,
        'tagline': tagline,
        'address': address,
        'phone': phone,
        'email': email,
        'ntn': ntn,
        'strn': strn,
        'ownerCompany': ownerCompany,
        'invoicePrefix': invoicePrefix,
        'dayStartHour': dayStartHour,
      };
  static StoreSettings fromJson(Map j) => StoreSettings(
        name: _s(j, 'name', 'Essence'),
        tagline: _s(j, 'tagline', 'Patisserie · Coffee · Moments'),
        address: _s(j, 'address', ''),
        phone: _s(j, 'phone', ''),
        email: _s(j, 'email', ''),
        ntn: _s(j, 'ntn', ''),
        strn: _s(j, 'strn', ''),
        ownerCompany: _s(j, 'ownerCompany', 'Mix & Match Collection'),
        invoicePrefix: _s(j, 'invoicePrefix', 'ESS'),
        dayStartHour: _i(j, 'dayStartHour', 4),
      );
  StoreSettings copyWith({
    String? name,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? ntn,
    String? strn,
    String? ownerCompany,
    String? invoicePrefix,
    int? dayStartHour,
  }) =>
      StoreSettings(
        name: name ?? this.name,
        tagline: tagline ?? this.tagline,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        ntn: ntn ?? this.ntn,
        strn: strn ?? this.strn,
        ownerCompany: ownerCompany ?? this.ownerCompany,
        invoicePrefix: invoicePrefix ?? this.invoicePrefix,
        dayStartHour: dayStartHour ?? this.dayStartHour,
      );
}

class PricingSettings {
  const PricingSettings({this.pricesIncludeTax = false, this.cashRoundingRupees = 0});
  final bool pricesIncludeTax;

  /// 0 = no rounding, otherwise 1, 5 or 10.
  final int cashRoundingRupees;
  Map<String, dynamic> toJson() => {'pricesIncludeTax': pricesIncludeTax, 'cashRoundingRupees': cashRoundingRupees};
  static PricingSettings fromJson(Map j) =>
      PricingSettings(pricesIncludeTax: _b(j, 'pricesIncludeTax', false), cashRoundingRupees: _i(j, 'cashRoundingRupees', 0));
}

class OrderTypeSettings {
  const OrderTypeSettings({
    this.dineIn = true,
    this.takeaway = true,
    this.delivery = true,
    this.defaultType = OrderType.takeaway,
    this.requireTableForDineIn = true,
    this.requirePhoneForDelivery = true,
  });
  final bool dineIn, takeaway, delivery, requireTableForDineIn, requirePhoneForDelivery;
  final OrderType defaultType;

  bool enabled(OrderType t) => switch (t) { OrderType.dineIn => dineIn, OrderType.takeaway => takeaway, OrderType.delivery => delivery };
  List<OrderType> get enabledTypes {
    final l = OrderType.values.where(enabled).toList();
    return l.isEmpty ? [OrderType.takeaway] : l;
  }

  OrderType get effectiveDefault => enabled(defaultType) ? defaultType : enabledTypes.first;

  Map<String, dynamic> toJson() => {
        'dineIn': dineIn,
        'takeaway': takeaway,
        'delivery': delivery,
        'defaultType': defaultType.key,
        'requireTableForDineIn': requireTableForDineIn,
        'requirePhoneForDelivery': requirePhoneForDelivery,
      };
  static OrderTypeSettings fromJson(Map j) => OrderTypeSettings(
        dineIn: _b(j, 'dineIn', true),
        takeaway: _b(j, 'takeaway', true),
        delivery: _b(j, 'delivery', true),
        defaultType: OrderType.parse(j['defaultType'] as String?),
        requireTableForDineIn: _b(j, 'requireTableForDineIn', true),
        requirePhoneForDelivery: _b(j, 'requirePhoneForDelivery', true),
      );
}

class ChargeSettings {
  const ChargeSettings({
    this.serviceEnabled = false,
    this.serviceBp = 1000,
    this.serviceDineInOnly = true,
    this.serviceTaxable = true,
    this.deliveryEnabled = true,
    this.deliveryAmount = 15000,
    this.deliveryTaxable = false,
    this.fbrFeeEnabled = true,
    this.fbrFeeAmount = 100,
  });
  final bool serviceEnabled, serviceDineInOnly, serviceTaxable, deliveryEnabled, deliveryTaxable, fbrFeeEnabled;
  final int serviceBp, deliveryAmount, fbrFeeAmount;

  List<ChargeRule> rulesFor(OrderType type) => [
        if (serviceEnabled && (!serviceDineInOnly || type == OrderType.dineIn))
          ChargeRule(type: ChargeType.service, label: 'Service charge', mode: ChargeMode.percent, value: serviceBp, taxable: serviceTaxable),
        if (deliveryEnabled && type == OrderType.delivery)
          ChargeRule(type: ChargeType.delivery, label: 'Delivery charge', mode: ChargeMode.fixed, value: deliveryAmount, taxable: deliveryTaxable),
      ];

  int get fbrFee => fbrFeeEnabled ? fbrFeeAmount : 0;

  Map<String, dynamic> toJson() => {
        'serviceEnabled': serviceEnabled,
        'serviceBp': serviceBp,
        'serviceDineInOnly': serviceDineInOnly,
        'serviceTaxable': serviceTaxable,
        'deliveryEnabled': deliveryEnabled,
        'deliveryAmount': deliveryAmount,
        'deliveryTaxable': deliveryTaxable,
        'fbrFeeEnabled': fbrFeeEnabled,
        'fbrFeeAmount': fbrFeeAmount,
      };
  static ChargeSettings fromJson(Map j) => ChargeSettings(
        serviceEnabled: _b(j, 'serviceEnabled', false),
        serviceBp: _i(j, 'serviceBp', 1000),
        serviceDineInOnly: _b(j, 'serviceDineInOnly', true),
        serviceTaxable: _b(j, 'serviceTaxable', true),
        deliveryEnabled: _b(j, 'deliveryEnabled', true),
        deliveryAmount: _i(j, 'deliveryAmount', 15000),
        deliveryTaxable: _b(j, 'deliveryTaxable', false),
        fbrFeeEnabled: _b(j, 'fbrFeeEnabled', true),
        fbrFeeAmount: _i(j, 'fbrFeeAmount', 100),
      );
}

class DiscountSettings {
  const DiscountSettings({
    this.presets = const [
      Discount.percent(500, label: '5%'),
      Discount.percent(1000, label: '10%'),
      Discount.percent(1500, label: '15%'),
      Discount.percent(2000, label: 'Staff 20%'),
      Discount.amount(10000, label: 'Rs 100 off'),
    ],
    this.cashierMaxBp = 1000,
    this.requireReason = true,
  });
  final List<Discount> presets;

  /// Largest discount a cashier can give without a manager PIN (basis points of the bill).
  final int cashierMaxBp;
  final bool requireReason;

  Map<String, dynamic> toJson() => {
        'presets': presets.map((d) => d.toJson()).toList(),
        'cashierMaxBp': cashierMaxBp,
        'requireReason': requireReason,
      };
  static DiscountSettings fromJson(Map j) => DiscountSettings(
        presets: j['presets'] is List ? (j['presets'] as List).map(Discount.fromJson).whereType<Discount>().toList() : const DiscountSettings().presets,
        cashierMaxBp: _i(j, 'cashierMaxBp', 1000),
        requireReason: _b(j, 'requireReason', true),
      );
}

class ReceiptSettings {
  const ReceiptSettings({
    this.header = '',
    this.footer = 'Thank you for visiting Essence!',
    this.showLogo = true,
    this.showTaxBreakdown = true,
    this.showCashier = true,
    this.showToken = true,
    this.autoPrintReceipt = true,
    this.receiptCopies = 1,
    this.printKotOnPay = true,
    this.kotCopies = 1,
  });
  final String header, footer;
  final bool showLogo, showTaxBreakdown, showCashier, showToken, autoPrintReceipt, printKotOnPay;
  final int receiptCopies, kotCopies;

  Map<String, dynamic> toJson() => {
        'header': header,
        'footer': footer,
        'showLogo': showLogo,
        'showTaxBreakdown': showTaxBreakdown,
        'showCashier': showCashier,
        'showToken': showToken,
        'autoPrintReceipt': autoPrintReceipt,
        'receiptCopies': receiptCopies,
        'printKotOnPay': printKotOnPay,
        'kotCopies': kotCopies,
      };
  static ReceiptSettings fromJson(Map j) => ReceiptSettings(
        header: _s(j, 'header', ''),
        footer: _s(j, 'footer', const ReceiptSettings().footer),
        showLogo: _b(j, 'showLogo', true),
        showTaxBreakdown: _b(j, 'showTaxBreakdown', true),
        showCashier: _b(j, 'showCashier', true),
        showToken: _b(j, 'showToken', true),
        autoPrintReceipt: _b(j, 'autoPrintReceipt', true),
        receiptCopies: _i(j, 'receiptCopies', 1),
        printKotOnPay: _b(j, 'printKotOnPay', true),
        kotCopies: _i(j, 'kotCopies', 1),
      );
}

enum FbrMode {
  sandbox('FBR Sandbox (testing)'),
  live('FBR Live');

  const FbrMode(this.label);
  final String label;
  static FbrMode parse(String? v) => v == 'sandbox' ? FbrMode.sandbox : FbrMode.live;
}

/// FBR POS integration. When [enabled] is off, sales skip FBR entirely: no FBR fee,
/// no fiscal invoice number and nothing is queued for reporting.
class FbrSettings {
  const FbrSettings({this.enabled = false, this.mode = FbrMode.live, this.posId = '', this.token = '', this.pctCode = ''});
  final bool enabled;
  final FbrMode mode;

  /// POS ID issued by FBR for this outlet.
  final String posId;

  /// Security token issued by FBR (sent as a Bearer token).
  final String token;

  /// Default PCT (HS) code reported for items.
  final String pctCode;

  bool get hasCredentials => posId.trim().isNotEmpty && token.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'enabled': enabled, 'mode': mode.name, 'posId': posId, 'token': token, 'pctCode': pctCode};
  static FbrSettings fromJson(Map j) => FbrSettings(
        enabled: _b(j, 'enabled', false),
        mode: FbrMode.parse(j['mode'] as String?),
        posId: _s(j, 'posId', ''),
        token: _s(j, 'token', ''),
        pctCode: _s(j, 'pctCode', ''),
      );
}

/// Pickup orders from the store website (they arrive as held orders tagged WEB).
class OnlineOrderSettings {
  const OnlineOrderSettings({
    this.accepting = false,
    this.whatsapp = '',
    this.hours = '',
    this.sendToBar = false,
    this.placedTemplate = defaultPlaced,
    this.readyTemplate = defaultReady,
    this.cancelledTemplate = defaultCancelled,
  });

  /// The website takes orders only while this is on (and a till is receiving them).
  final bool accepting;

  /// Shop WhatsApp number shown on the website, e.g. 03001234567.
  final String whatsapp;

  /// Opening hours shown on the website, e.g. "Daily 12 pm – 12 am".
  final String hours;

  /// Print a bar ticket as soon as an online order arrives.
  final bool sendToBar;

  final String placedTemplate;
  final String readyTemplate;
  final String cancelledTemplate;

  static const placeholders = '{name} {code} {items} {subtotal} {store}';

  static const defaultPlaced = 'Hi {name}! Your {store} order #{code} has been placed.\n\n{items}\nSubtotal: {subtotal} '
      '(GST is added at the counter based on your payment method).\n\n'
      'Please visit us at {store}, Bahria Town Phase 8 to collect your order. Just show your Order ID #{code}.';
  static const defaultReady = 'Hi {name}, your {store} order #{code} is ready for pickup. See you soon!';
  static const defaultCancelled = 'Hi {name}, sorry, we couldn\'t take your {store} order #{code}. '
      'Please reply here or call us and we\'ll help you out.';

  Map<String, dynamic> toJson() => {
        'accepting': accepting,
        'whatsapp': whatsapp,
        'hours': hours,
        'sendToBar': sendToBar,
        'placedTemplate': placedTemplate,
        'readyTemplate': readyTemplate,
        'cancelledTemplate': cancelledTemplate,
      };

  static OnlineOrderSettings fromJson(Map j) => OnlineOrderSettings(
        accepting: _b(j, 'accepting', false),
        whatsapp: _s(j, 'whatsapp', ''),
        hours: _s(j, 'hours', ''),
        sendToBar: _b(j, 'sendToBar', false),
        placedTemplate: _s(j, 'placedTemplate', defaultPlaced),
        readyTemplate: _s(j, 'readyTemplate', defaultReady),
        cancelledTemplate: _s(j, 'cancelledTemplate', defaultCancelled),
      );
}

class SecuritySettings {
  const SecuritySettings({this.autoLockMinutes = 5, this.requireOpenShift = true});

  /// 0 = never auto-lock.
  final int autoLockMinutes;
  final bool requireOpenShift;
  Map<String, dynamic> toJson() => {'autoLockMinutes': autoLockMinutes, 'requireOpenShift': requireOpenShift};
  static SecuritySettings fromJson(Map j) =>
      SecuritySettings(autoLockMinutes: _i(j, 'autoLockMinutes', 5), requireOpenShift: _b(j, 'requireOpenShift', true));
}

enum Role {
  owner('Owner'),
  manager('Manager'),
  cashier('Cashier');

  const Role(this.label);
  final String label;
  static Role parse(String? v) => Role.values.firstWhere((r) => r.name == v, orElse: () => Role.cashier);
}

enum Perm {
  discountOverride('Give discounts above the cashier limit'),
  voidOrder('Void paid orders'),
  refund('Refund orders'),
  openDrawer('Open cash drawer without a sale'),
  cashInOut('Record cash in / cash out'),
  closeShift('Close shift & print Z-report'),
  viewReports('View reports'),
  manageInventory('Stock-in, adjustments & recipes'),
  manageMenu('Edit menu & prices'),
  manageStaff('Manage staff & permissions'),
  manageSettings('Change settings');

  const Perm(this.label);
  final String label;
}

class PermissionSettings {
  const PermissionSettings(this.byRole);
  final Map<Role, Set<Perm>> byRole;

  static const defaults = PermissionSettings({
    Role.manager: {
      Perm.discountOverride,
      Perm.voidOrder,
      Perm.refund,
      Perm.openDrawer,
      Perm.cashInOut,
      Perm.closeShift,
      Perm.viewReports,
      Perm.manageInventory,
      Perm.manageMenu,
    },
    Role.cashier: {Perm.cashInOut},
  });

  /// Owners always have every permission.
  bool allows(Role role, Perm p) => role == Role.owner || (byRole[role]?.contains(p) ?? false);

  PermissionSettings toggle(Role role, Perm p, bool on) {
    final next = {for (final e in byRole.entries) e.key: {...e.value}};
    final set = next.putIfAbsent(role, () => <Perm>{});
    on ? set.add(p) : set.remove(p);
    return PermissionSettings(next);
  }

  Map<String, dynamic> toJson() => {for (final e in byRole.entries) e.key.name: e.value.map((p) => p.name).toList()};
  static PermissionSettings fromJson(Map j) {
    if (j.isEmpty) return defaults;
    return PermissionSettings({
      for (final r in [Role.manager, Role.cashier])
        r: {
          for (final n in (j[r.name] as List? ?? const []))
            ...Perm.values.where((p) => p.name == n),
        },
    });
  }
}

/// Everything the POS needs from store settings, resolved with defaults.
class AppSettings {
  const AppSettings({
    this.store = const StoreSettings(),
    this.pricing = const PricingSettings(),
    this.orderTypes = const OrderTypeSettings(),
    this.charges = const ChargeSettings(),
    this.discounts = const DiscountSettings(),
    this.receipt = const ReceiptSettings(),
    this.fbr = const FbrSettings(),
    this.security = const SecuritySettings(),
    this.permissions = PermissionSettings.defaults,
    this.online = const OnlineOrderSettings(),
  });
  final StoreSettings store;
  final PricingSettings pricing;
  final OrderTypeSettings orderTypes;
  final ChargeSettings charges;
  final DiscountSettings discounts;
  final ReceiptSettings receipt;
  final FbrSettings fbr;
  final SecuritySettings security;
  final PermissionSettings permissions;
  final OnlineOrderSettings online;

  static AppSettings fromMaps(Map<String, Map<String, dynamic>> m) => AppSettings(
        store: StoreSettings.fromJson(m[SettingKeys.store] ?? const {}),
        pricing: PricingSettings.fromJson(m[SettingKeys.pricing] ?? const {}),
        orderTypes: OrderTypeSettings.fromJson(m[SettingKeys.orderTypes] ?? const {}),
        charges: ChargeSettings.fromJson(m[SettingKeys.charges] ?? const {}),
        discounts: DiscountSettings.fromJson(m[SettingKeys.discounts] ?? const {}),
        receipt: ReceiptSettings.fromJson(m[SettingKeys.receipt] ?? const {}),
        fbr: FbrSettings.fromJson(m[SettingKeys.fbr] ?? const {}),
        security: SecuritySettings.fromJson(m[SettingKeys.security] ?? const {}),
        permissions: PermissionSettings.fromJson(m[SettingKeys.permissions] ?? const {}),
        online: OnlineOrderSettings.fromJson(m[SettingKeys.online] ?? const {}),
      );

  Map<String, Map<String, dynamic>> toMaps() => {
        SettingKeys.store: store.toJson(),
        SettingKeys.pricing: pricing.toJson(),
        SettingKeys.orderTypes: orderTypes.toJson(),
        SettingKeys.charges: charges.toJson(),
        SettingKeys.discounts: discounts.toJson(),
        SettingKeys.receipt: receipt.toJson(),
        SettingKeys.fbr: fbr.toJson(),
        SettingKeys.security: security.toJson(),
        SettingKeys.permissions: permissions.toJson(),
        SettingKeys.online: online.toJson(),
      };
}
