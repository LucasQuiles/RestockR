import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './widgets/subscription_item_widget.dart';
import 'notifier/watchlist_management_notifier.dart';

class WatchlistManagementScreen extends ConsumerStatefulWidget {
  WatchlistManagementScreen({Key? key}) : super(key: key);

  @override
  WatchlistManagementScreenState createState() =>
      WatchlistManagementScreenState();
}

class WatchlistManagementScreenState
    extends ConsumerState<WatchlistManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Column(
            children: [
              Expanded(
                child: _buildSubscriptionsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildSubscriptionsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(watchlistManagementNotifier);

          // Listen for unsubscribe success
          ref.listen(
            watchlistManagementNotifier,
            (previous, current) {
              if (!(previous?.isUnsubscribeSuccess ?? false) &&
                  (current.isUnsubscribeSuccess ?? false)) {
                showAppToast(
                  context,
                  message: 'Successfully unsubscribed from product',
                  variant: AppToastVariant.warning,
                );
                // Reset the state after showing snackbar
                Future.delayed(Duration(milliseconds: 100), () {
                  ref
                      .read(watchlistManagementNotifier.notifier)
                      .resetUnsubscribeState();
                });
              }
            },
          );

          if (state.isLoading ?? false) {
            return Center(
              child: CircularProgressIndicator(
                color: appTheme.red_500,
              ),
            );
          }

          final items = state.watchlistManagementModel?.subscriptionItems ?? [];

          if (items.isEmpty) {
            return Center(
              child: Text(
                'No subscriptions found',
                style: TextStyleHelper.instance.title16MediumInter,
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 8.h);
            },
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return SubscriptionItemWidget(
                model: item,
                onUnsubscribe: () {
                  onTapUnsubscribe(context, item.id ?? '');
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Handles unsubscribe action for a subscription item
  void onTapUnsubscribe(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Unsubscribe'),
        content:
            Text('Are you sure you want to unsubscribe from this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(watchlistManagementNotifier.notifier)
                  .onUnsubscribe(itemId);
            },
            child: Text(
              'Unsubscribe',
              style: TextStyleHelper.instance.textStyle10,
            ),
          ),
        ],
      ),
    );
  }
}
