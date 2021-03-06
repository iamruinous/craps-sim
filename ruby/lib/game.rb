class Game
  attr_accessor :shooter, :dice, :dealer, :point

  def initialize(args)
    @point   = nil
    @shooter = Shooter.new({:bet => args[:bet], :odds => args[:odds]})
    @dealer  = Dealer.new
  end

  # DOESN'T WORK AS EXPECTED
  def start
    LOGGER.info "[INFO] Starting New Game #{Time.now.to_i}"
    while @shooter.has_bankroll?
      LOGGER.info "[INFO] Coming Out"
      comeout_roll
      if @point
        while @shooter.still_shooting?
          LOGGER.info "[INFO] Still Shooting..."
          proceed
        end
      else
        LOGGER.info "[INFO] Still Establishing Point..."
        next
      end
    end
    LOGGER.debug "\t[INFO] Roll Ended, Shooter has $#{shooter.bankroll}"
    # Stat.new({:won_amount => @shooter.won_amount, :loss_amount => @shooter.loss_amount, :outcome => @shooter.outcome?})
    {:starting_bankroll => @shooter.starting_bankroll, :bankroll => @shooter.bankroll, :win => @shooter.win?, :loss => @shooter.loss?}
  end

private

  def proceed
    roll = @shooter.shoot(@point)
    LOGGER.debug "\t[INFO] Shooter rolls a #{roll}"
    if @dealer.point_made?(roll, @point)
      @dealer.pay(@shooter, roll)
      @shooter.points_hit += 1
      @shooter.still_shooting = false
      @point = nil
      LOGGER.debug "\t[WIN]  Shooter hits their point of #{roll} $(#{@shooter.bankroll})"
    elsif @dealer.seven_out?(roll)
      @dealer.clear_bets(@shooter)
      @shooter.still_shooting = false
      @point = nil
      LOGGER.debug "\t[LOSS] Shooter sevens out $(#{@shooter.bankroll})"
    else
      @shooter.numbers_rolled << roll
    end
  end

  def comeout_roll
    roll = @shooter.comeout
    LOGGER.debug "\t[INFO] Shooter rolls a #{roll}"

    if @dealer.point_established?(roll)
      @shooter.coming_out = false
      LOGGER.debug "\t[INFO] Shooter Establishes a Point of #{roll}"
      @point = roll
    end

    if @dealer.seven_eleven?(roll)
      @shooter.comeout_wins += 1
      @dealer.pay(@shooter, roll)
      LOGGER.debug "\t[WIN]  Seven Eleven! $(#{@shooter.bankroll})"
    end

    if @dealer.craps?(roll)
      @shooter.comeout_losses += 1
      @dealer.clear_bets(@shooter)
      LOGGER.debug "\t[LOSS] Craps! $(#{@shooter.bankroll})"
    end
    @shooter.still_shooting = true
    return true
  end

end