import React from "react";
import PropTypes from "prop-types";

export default class CouponRemover extends React.Component {
  render() {
    const coupon = this.props.rootState.coupon;

    return (
      <div className="discount-coupon__box discount-coupon-applied-box p-1">
        <div className="discount-coupon-applied-box__message font-semibold">
          Coupon with code{" "}
          <span className="discount-coupon-applied--code dark-secondary">
            {coupon.code}
          </span>{" "}
          applied!
          <p className="mt-2">You have unlocked {coupon.discount}% discount.</p>
        </div>

        {_.isString(coupon.instructions) && (
          <div className="coupon-instructions mt-2">
            <p>
              <span className="font-semibold">Note: {coupon.instructions}</span>
            </p>
          </div>
        )}

        <button className="btn btn-ghost-secondary btn-sm text-uppercase mt-2">
          Remove
        </button>
      </div>
    );
  }
}

CouponRemover.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};