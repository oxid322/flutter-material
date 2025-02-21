// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/material.dart';
import 'package:mdc_104/login.dart';
import 'model/product.dart';

//TODO: Add velocity constant
const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget{
  final Category currentCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;

  const Backdrop({
    required this.currentCategory,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    Key? key,
  }) : super(key: key);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');

  //TODO: Add AnimationController widget
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 300),
    );
  }
    //TODO: add override for didUpdateWidget
  @override
  void didUpdateWidget(Backdrop old) {
    super.didUpdateWidget(old);

    if (widget.currentCategory != old.currentCategory){
      _toggleBackdropVisibility();
    } else if(!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.forward
        || status == AnimationStatus.completed;
  }

  void _toggleBackdropVisibility(){
    _controller.fling(
      velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: [
        ExcludeSemantics(
          child: widget.backLayer,
          excluding: _frontLayerVisible,
        ),
        PositionedTransition(
            rect: layerAnimation,
            child: _FrontLayer(
                onTap: _toggleBackdropVisibility,
                child: widget.frontLayer

            ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      elevation: 0.0,
      titleSpacing: 0.0,

      title: _BackDropTitle(
          onPress: _toggleBackdropVisibility,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
          listenable: _controller.view
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.search,
            semanticLabel: 'login',
          ),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LoginPage()),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.tune,
            semanticLabel: 'login',
          ),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LoginPage()),
            );
          },
        ),
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }
}
class _FrontLayer extends StatelessWidget{
  //TODO: Add on-tap callback
  const _FrontLayer({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key : key);

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //TODO: Add a GestureDetector
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
class _BackDropTitle extends StatelessWidget {
  final void Function() onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackDropTitle({
    Key? key,
    required this.onPress,
    required this.frontTitle,
    required this.backTitle,
    required Animation<double> listenable
  }) : _listenable = listenable,
        super(key : key);

  final Animation<double> _listenable;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = _listenable;

    return DefaultTextStyle(
        style: Theme.of(context).textTheme.titleLarge!,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: Row(children: <Widget>[
          SizedBox(
            width: 72.0,
            child: IconButton(
              padding: const EdgeInsets.only(right: 8.0),
              onPressed: onPress,
              icon: Stack(children: [
                Opacity(
                  opacity: animation.value,
                  child: const ImageIcon(AssetImage('assets/slanted_menu.png')),
                ),
                FractionalTranslation(
                  translation: Tween<Offset>(
                    begin: Offset.zero,
                    end: Offset(1.0, 0.0),
                  ).evaluate(animation),
                  child: const ImageIcon(AssetImage('assets/diamond.png')),
                ),
              ],),
            ),
          ),
          Stack(
            children: [
              Opacity(
                opacity: CurvedAnimation(
                    parent: ReverseAnimation(animation),
                    curve: const Interval(0.5, 1.0),
                ).value,
                child: FractionalTranslation(
                  translation: Tween<Offset>(
                    begin: Offset.zero,
                    end: Offset(0.5, 0.0),
                  ).evaluate(animation),
                  child: backTitle,
                ),
              ),
              Opacity(
                opacity: CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.5, 1.0),
                ).value,
                child: FractionalTranslation(
                  translation: Tween<Offset>(
                    begin: const Offset(-0.25, 0.0),
                    end: Offset.zero,
                  ).evaluate(animation),
                  child: frontTitle,
                ),
              ),
            ],
          )
        ]),
    );
  }
}

