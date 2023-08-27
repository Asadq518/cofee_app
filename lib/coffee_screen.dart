import 'package:flutter/material.dart';

import 'coffee.dart';

class CoffeeScreen extends StatefulWidget {
  const CoffeeScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeScreen> createState() => _CoffeeScreenState();
}

class _CoffeeScreenState extends State<CoffeeScreen> {
  final _pageCoffeeController = PageController(
    viewportFraction: 0.35,
  );
  final _pageTextController = PageController();
  double _currentPage = 0.0;
  double _textPage = 0.0;

  void _coffeeScrollListener() {
    setState(() {
      _currentPage = _pageCoffeeController.page!;
    });
  }

  void _textScrollListener() {
    setState(() {
      _textPage = _currentPage;
    });
  }

  @override
  void initState() {
    _pageCoffeeController.addListener(_coffeeScrollListener);
    _pageTextController.addListener(_textScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _pageCoffeeController.removeListener(_coffeeScrollListener);
    _pageCoffeeController.dispose();
    _pageTextController.removeListener(_textScrollListener);
    _pageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            //BottomSprayEffect
            bottomSprayEffect(size),
            //CoffeeList
            coffeePageView(size),
            //CoffeeTitleTextAndPrice
            coffeeTitle(size),
          ],
        ),
      ),
    );
  }

  Positioned bottomSprayEffect(Size size) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: -size.height * 0.22,
      height: size.height * 0.3,
      child: const DecoratedBox(
          decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.brown,
            offset: Offset.zero,
            blurRadius: 90,
            spreadRadius: 45,
          ),
        ],
      )),
    );
  }

  Positioned coffeeTitle(Size size) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      height: 110,
      child: Column(
        children: [
          Expanded(
              child: PageView.builder(
                  itemCount: coffees.length,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageTextController,
                  itemBuilder: (context, index) {
                    final opacity =
                        (1 - (index - _textPage).abs()).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.2),
                        child: Text(
                          coffees[index].name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  })),
          AnimatedSwitcher(
            duration: _duration,
            child: _currentPage.toInt() < coffees.length
                ? Text(
                    key: Key(coffees[_currentPage.toInt()].name),
                    '\$${coffees[_currentPage.toInt()].price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          )
        ],
      ),
    );
  }

  Transform coffeePageView(Size size) {
    return Transform.scale(
      scale: 1.6,
      alignment: Alignment.bottomCenter,
      child: PageView.builder(
          controller: _pageCoffeeController,
          itemCount: coffees.length + 1,
          scrollDirection: Axis.vertical,
          onPageChanged: (value) {
            if (value < coffees.length) {
              _pageTextController.animateToPage(value,
                  duration: _duration, curve: Curves.easeOut);
            }
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox.shrink();
            }
            final coffee = coffees[index - 1];
            final result = _currentPage - index + 1;
            final value = -0.4 * result + 1;
            final opacity = value.clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(
                    0.0,
                    size.height / 2.6 * (1 - value).abs(),
                  )
                  ..scale(value),
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    coffee.image,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            );
          }),
    );
  }
}

const _duration = Duration(milliseconds: 300);
